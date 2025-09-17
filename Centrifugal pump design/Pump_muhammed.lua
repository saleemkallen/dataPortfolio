--------------------------------   CENTRIFUGAL PUMP WITH OPRN SINGLE VANE IMPELLER  ------------------------$$ parameter declaration $$--------

height_cone=ui_scalar("Height of cone",17,1,20)                  -------------- Height of the cone
num_steps=200                                                     -------------- Number of steps for the generation of parts
height_bottom=ui_scalar("Height of bottom vane ",25,1,35)           -------------- Height bottom vane
height_top=ui_scalar("Height of top vane",21,1,25)                  -------------- Height top vane
radius_1=ui_scalar("Radius of top vane",42,1,45)                    -------------- Radius top vane
radius_cone_outlet=.6*radius_1                                   -------------- Radius of cone outlet
thick=ui_scalar("Thickness of the vane",8,1,10)                   -------------- Thickness of the vane
thickness_angle=thick/radius_cone_outlet     
wrap_angle = ui_scalar("Wrap angle of the vane",360.0,1.0,540.0)  -------------- Wrap angle of the vane
angle_offset=3.0                             --------------Value determining the slope of top and bottom profile of the vane
cone_base_thickness =  0.1*height_cone                 ---------- Thickness of the base of the imepller

-- NB: The code for casing is defined prior to the code of the impeller due to some constraints mentioned later in the code----

           -----------------------------------xx  CASING  xx------------------------
function table_reverse(in_table)
   -- Order a table in reverse order: out_table= in_table(n->1)
   local out_table= {}
   for i= #in_table,1,-1 do
      out_table[i]= in_table[#in_table-i+1]
   end
return out_table
end
-------------------------------------------------------------------------------------------------

radius_c=radius_1
function casing_curve(radius_c)
--The centerline of the casing is done using a logarithmic spiral and the constants can be varied to create accurate casing .
    casing_curve_r={}    
    thetaStart=0.0
    --local numPoints = 100  
    local thetaEnd = 2 * math.pi
    local thetaStep = (thetaEnd - thetaStart) / num_steps
    local b = 0.1  -- Spiral growth rate
    point={}
    r_value={}

    for i = 1, num_steps do
        local theta = thetaStart + (i - 1) * thetaStep
         r = radius_c * math.exp(b * theta)

         x = r * math.cos(theta)
         y = r * math.sin(theta)

   table.insert(point,v(x,y))
   table.insert(casing_curve_r,v(r,theta*(180/math.pi)))
   table.insert(r_value,r)
    end
        
return point,casing_curve_r,r_value
end
--------------------------------------------------------------------------------------
function circle(r)
--This function create the circluar cross section for the casing .
circle_points={}

    for i =1,360 do
        local angle = math.rad(i)
        local x = r * math.cos(angle)
        local y = r * math.sin(angle)
        circle_points[i]=v(x,y,0)
    end
    return circle_points
end

---------------------------- Constriant equations -------------------------------------

if(height_bottom>height_cone)  
  then

    r_casing=(1.2*(height_bottom+cone_base_thickness))/2

  else
    r_casing=(1.2*(height_cone+cone_base_thickness))/2
end

casing_curve,casing_r,r_c_val=casing_curve(radius_c)
r_c_max=(r_c_val[num_steps]-r_c_val[1])/2

if(r_casing>r_c_max)
  then
    r_casing=r_c_max
    height_bottom=r_c_max
    height_cone=.9*r_c_max
    height_top=.9*r_c_max
end
---------------------------------------------------------------------------------

function volute_volume(radius,curve,curve_r)
--This function creates a series of circular contours at the points genereated using the logarithmic spiral and then sections_extrude is done to join them together .
        local circle=table_reverse(circle(radius))        
          casing_tube={}
        local section_circle={}
        for j=1,#curve do

        for i=1,#circle_points do 
        
        section_circle[i]=translate(curve[j])*rotate(curve_r[j].y,Z)*rotate(90,X)*circle[i]
        end
        casing_tube[j]={}
          for k=1,#section_circle do
           casing_tube[j][k]=section_circle[k]
        end
        end
    
        return sections_extrude(casing_tube)
end 

outer_volute=volute_volume(r_casing,casing_curve,casing_r)
inner_volute=volute_volume(.9*r_casing,casing_curve,casing_r)
casing_volute_tube=difference(outer_volute,inner_volute)
--emit(casing_volute_tube)
cut=translate(v(0,0,-25))*linear_extrude(v(0,0,50),casing_curve)
casing_shell=difference(casing_volute_tube,cut)
--emit(casing_shell)
------------------------------------------------------------------------------------------------
function bottom_profile(angle,num_steps,radius_cone_outlet,beta,height,thickness)  --
--This function creates a line on the surface of the cone .taking radius as the radius of the cone at a height z.
  local x_array = {}
  local y_array = {}
  local z_array = {}
  for i=1,num_steps 
  do
    local theta = (thickness)+(i-1) *((angle*math.pi/180)/(num_steps - 1))
    local z = (i - 1) * (0.9*height / (num_steps - 1))
    local r = radius_cone_outlet-(z*(radius_cone_outlet/height))
    local x = r * math.cos(theta)
    local y = r * math.sin(theta) 

    x_array[i] = x
    y_array[i] = y
    z_array[i] = z
end    
   return x_array, y_array, z_array
end

---------------------------------------------------------------------------

function top_profile(angle,radius_1,num_steps,height_bottom,height_top,thickness,angle_offset) 
--This function creates a line on with shape of a helical spiral that varies by pitch.
  local x_array = {}
  local y_array = {}
  local z_array = {}

  for i=1,num_steps do
    local theta = (angle_offset*math.pi/180)+(thickness)+(i-1) *((angle*math.pi/180)/(num_steps - 1))
     r_1 = radius_1 + ((2 - radius_1) / (num_steps - 1)) * (i - 1)
    local x = r_1 * math.cos(theta)               
    local y = r_1 * math.sin(theta)               
    pitch=height_top/(2*math.pi*r_1)              
    local z = height_bottom+pitch*theta           
    x_array[i] = x
    y_array[i] = y
    z_array[i] = z
  end
  return x_array,y_array,z_array
end

-------------------------------$$ FUNCTION CALL $$-----------------------------------------------------

-- 4 lines are created to create a contour  of the thickness of the impeller blade.
local x_t_inner,y_t_inner,z_t_inner=top_profile(wrap_angle,radius_1,num_steps,height_bottom,height_top,0,angle_offset)
local x_t_outter,y_t_outter,z_t_outter = top_profile(wrap_angle,radius_1,num_steps,height_bottom,height_top,thickness_angle,angle_offset)

local x_b_inner,y_b_inner,z_b_inner = bottom_profile(wrap_angle,num_steps,radius_cone_outlet,beta,height_cone,0)
local x_b_outter,y_b_outter,z_b_outter = bottom_profile(wrap_angle,num_steps,radius_cone_outlet,beta,height_cone,thickness_angle)

----------------------------$$ IMPELLER PROFILE GENERATION $$-----------------------------------------------
-- The lines are then saved together and section extrude is done to generate the vane.
bottom_inner={}
bottom_outter={}
top_inner={}
top_outter={}
curve={}
for i=1,num_steps do
  table.insert(bottom_inner,v(x_b_inner[i],y_b_inner[i],z_b_inner[i]))
  table.insert(bottom_outter,v(x_b_outter[i],y_b_outter[i],z_b_outter[i]))

  table.insert(top_inner,v(x_t_inner[i],y_t_inner[i],z_t_inner[i]))
  table.insert(top_outter,v(x_t_outter[i],y_t_outter[i],z_t_outter[i]))
  
end

for i=1,num_steps do
table.insert(curve,{bottom_inner[i],top_inner[i],top_outter[i],bottom_outter[i]}) 
end
vane=sections_extrude(curve)

-------------

cone_profile=U(cone(radius_cone_outlet,0.09*radius_cone_outlet, height_cone),translate(v(0,0,-0.1*height_cone))*cylinder(radius_cone_outlet,cone_base_thickness))
vane_profile=union(vane,cone_profile)
--emit((vane_porfile))

-------------------------------- TOP CONE FOR THE CASING----------------------------------------------------

--The top of the cone is created usign the inbuilt cone function .
--top_radius=math.sqrt(top_outter[100].x^2+top_outter[100].y^2+top_outter[100].z^2)
outer_top=translate(v(0,0,r_casing-.5))*cone(radius_c+2,radius_cone_outlet,1.1*height_top)
inner_top=translate(v(0,0,r_casing-.5))*cone(0.9*radius_c,0.9*radius_cone_outlet,1.1*height_top)
casing_top_tube=difference(outer_top,inner_top)
--emit(casing_top_tube)
--------------------------covering the casing -------------------------------------------------

thickness_of_base_cover=r_casing*.1
top_cover=translate(v(0,0,r_casing-thickness_of_base_cover))*difference(linear_extrude(v(0,0,thickness_of_base_cover),casing_curve),cylinder(radius_c,50))
--emit(top_cover)
bottom_cover=translate(v(0,0,-r_casing))*linear_extrude(v(0,0,thickness_of_base_cover),casing_curve)
--emit(bottom_cover)
--------------------------------xx outlet cylinder  xx-------------------------

outlet_outer=translate(v(casing_curve[num_steps].x,casing_curve[num_steps].y-1))*rotate(0,0,casing_r[num_steps].y)*rotate(-90,0,0)*cylinder(1.1*r_casing,2*r_casing)
outlet_inner=translate(v(casing_curve[num_steps].x,casing_curve[num_steps].y-1))*rotate(0,0,casing_r[num_steps].y)*rotate(-90,0,0)*cylinder(r_casing,2*r_casing)
outlet_hollow=difference(outlet_outer,outlet_inner)

---------------------------- GAP COVER -----------------

----Covering the area gap between the outlet and the start of the volute casing.
vane_profile=translate(v(0,0,-(r_casing-cone_base_thickness-.1*r_casing)))*vane_profile

right={}
left={}
for k=1,360 do
right[k]=casing_tube[1][k] 

left[k]=casing_tube[num_steps][k]   
end

right_c=linear_extrude(v(0,1,0),right)
left_c=linear_extrude(v(0,1,0),left)
right_cut=translate(0,5,0)*linear_extrude(v(0,-11,0),right)
cap=difference(convex_hull(union(right_c,left_c)),outlet_outer)
cap=difference(cap,right_cut)


-----------------------------------------------------------------------------------------------
shaft_radius = 6
shaft_height=20
function shaft(clearance)  ---- function for the shaft cylinder
shft =translate(0,0,-21)*cylinder(shaft_radius+clearance,shaft_height)
return shft
end


casing1=union({casing_shell,top_cover,casing_top_tube,casing_top_tube,outlet_hollow,bottom_cover,cap})

casing2=difference(casing1,shaft(0))
--emit(casing2)
---------------------------- handle for the rotation -----------------

radius = v(3,0,0)

------bottom part ----
triangle = { radius + v(1,0,0), radius + v(0,2,0), radius + v(-1,0,0) }
handle_ring1=rotate_extrude( triangle, 100 )
HR1=( translate(v(0,0,20))*handle_ring1 )
triangle = { radius + v(1,0,0), radius + v(-1,0,0), radius + v(0,-1,0) }
handle_ring2=rotate_extrude( triangle, 100 )
HR2=( translate(v(0,0,20))*handle_ring2 )
HR=U(HR1,HR2)
bottom_c=(cylinder(4,40))

--emit( (translate(v(0,0,-1))*U(bottom_c,HR)),29) -- with the imoeller

 ------top part ----

c1=translate(v(0,0,25))*cylinder(4.1,15)
c2=translate(v(0,0,25))*cylinder(5,22) 
C=(translate(v(0,0,1))*difference(  c2,c1))

top_c=(translate(v(0,0,46))*cylinder(4,40))
hand1= U(C,top_c)
hand2=(translate(v(-22.5,0,85))*rotate(90,Y)*cylinder(4,45))
--emit(translate(v(0,0,-5))*U(hand1,hand2))


-------------------------- screws--------
--[[screws1 = union((rotate(90,Z)*translate(30,30,-19)*cone(2.5,4.8,(16-11))),
(rotate(180,Z)*translate(30,30,-19)*cone(2.5,4.8,(16-11))))
screws2 = union((rotate(270,Z)*translate(30,30,-19)*cone(2.5,4.8,(16-11))),
(rotate(360,Z)*translate(30,30,-19)*cone(2.5,4.8,(16-11))))
screws = U(screws1,screws2) -- slots for the screws for the casing
--]]
-------------------------------------
f = font()
text = f:str('GROUP 17', 5)
text=(rotate(90,Z)*translate(-35,42,15.4)*text) --- text - group name

--casing_final=U(text,difference(casing2,screws))
casing_final=U(text,casing2)

--emit(casing_final,2)  -------------------------------------- final casing geometry

impeller = difference((translate(0,0,.2)*vane_profile),shaft(.4))

--emit(impeller,29)  --------------------------------------- final impeller geometry

----------------------shaft and base---------------

emit(shaft(0))  -- shaft
emit((translate(0,0,-24.5)*cylinder(55,9))) --base
----------------- check size ---------
dx=148
dy=210
dz=9
bbox=box(dx,dy,dz)
--emit(rotate(90,Z)*bbox)

----------------for sectional view ------------------

p=translate(v(20,20,-1))*cylinder(40,60)
--emit(difference(casing_final,p))

----------------    Slicers ------------------

slicer1=translate(v(0,0,-50))*cylinder(120,50)
slicer2=translate(v(0,0,0))*cylinder(120,50)
--emit(scale(1)*translate(v(0,0,30))*difference(casing_final,slicer1),2) -- top part of the casing

--emit(scale(1)*translate(v(0,0,30))*difference(casing_final,slicer2),2)  -- bottom part of the casing