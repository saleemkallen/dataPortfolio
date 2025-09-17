import React, { useState, useEffect } from 'react';
import './dataengineer.css';

const DataEngineerPortfolio: React.FC = () => {
  const [activeTab, setActiveTab] = useState('projects');
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const skills = {
    programming: [
      { name: 'Python', level: 95, category: 'Expert' },
      { name: 'SQL', level: 90, category: 'Expert' },
      { name: 'R Programming', level: 80, category: 'Advanced' },
      { name: 'MATLAB', level: 85, category: 'Advanced' },
      { name: 'JavaScript/TypeScript', level: 75, category: 'Intermediate' }
    ],
    dataTools: [
      { name: 'Power BI', level: 90, category: 'Expert' },
      { name: 'Elasticsearch', level: 88, category: 'Expert' },
      { name: 'ETL Pipelines', level: 80, category: 'Advanced' },
      { name: 'DAX Studio', level: 85, category: 'Advanced' },
      { name: 'PowerQuery', level: 82, category: 'Advanced' }
    ],
    cloud: [
      { name: 'Microsoft Azure', level: 78, category: 'Intermediate' },
      { name: 'AWS', level: 70, category: 'Intermediate' },
      { name: 'CI/CD Pipelines', level: 80, category: 'Advanced' },
      { name: 'Docker', level: 75, category: 'Intermediate' }
    ],
    analytics: [
      { name: 'Machine Learning', level: 85, category: 'Advanced' },
      { name: 'NLP', level: 88, category: 'Expert' },
      { name: 'Time Series Analysis', level: 85, category: 'Advanced' },
      { name: 'Statistical Analysis', level: 90, category: 'Expert' },
      { name: 'Data Visualization', level: 88, category: 'Expert' }
    ]
  };

  const projects = [
    {
      id: 1,
      title: "AI-Driven Data Pipeline & Chatbot System",
      description: "Developed an advanced data processing pipeline using RAG (Retrieval-Augmented Generation) and Elasticsearch for enterprise knowledge management. Built automated data ingestion, processing, and retrieval systems serving 500+ internal users.",
      technologies: ["Python", "Elasticsearch", "Azure OpenAI", "Flask", "RAG", "NLP"],
      achievements: [
        "Reduced data retrieval time by 60% through optimized Elasticsearch queries",
        "Improved user query accuracy by 45% using RAG implementation",
        "Processed 10,000+ documents with 99.2% uptime",
        "Built automated ETL pipeline handling 50GB+ daily data"
      ],
      github: "https://github.com/saleemkallen",
      demo: "Master thesis/demo.mp4"
    },
    {
      id: 2,
      title: "Geospatial Data Analysis & Remote Sensing",
      description: "Conducted comprehensive land use and land cover classification analysis using Quantum GIS and R programming. Implemented NDVI analysis for forest health assessment and erosion-prone zone identification across 4-year dataset (2019-2022).",
      technologies: ["R", "Quantum GIS", "Remote Sensing", "NDVI Analysis", "Spatial Statistics"],
      achievements: [
        "Analyzed 15,000+ hectares of land use data",
        "Identified 12 erosion-prone zones with 94% accuracy",
        "Generated automated reports for environmental monitoring",
        "Reduced manual analysis time by 70% through R automation"
      ],
      github: "https://github.com/saleemkallen",
      demo: "GIS and R/GIS_Land_use_Land_Cover.pdf"
    },
    {
      id: 3,
      title: "Time Series Analysis & Predictive Modeling",
      description: "Performed advanced dendroecological analysis using R to assess drought resilience in tree species. Developed predictive models comparing growth patterns of Douglas Fir, Norway Spruce, and Pedunculate Oak during significant drought events.",
      technologies: ["R", "Time Series Analysis", "Statistical Modeling", "Dendrochronology", "Climate Data"],
      achievements: [
        "Analyzed 30+ years of tree ring data",
        "Developed drought resilience scoring system",
        "Created automated visualization dashboards",
        "Achieved 89% accuracy in drought impact prediction"
      ],
      github: "https://github.com/saleemkallen",
      demo: "Time series/Time series analysis.pdf"
    },
    {
      id: 4,
      title: "Business Intelligence & Data Visualization",
      description: "Designed and implemented comprehensive Power BI dashboards for business intelligence reporting. Created automated data refresh pipelines and interactive visualizations for executive decision-making.",
      technologies: ["Power BI", "DAX", "PowerQuery", "SQL Server", "Data Modeling"],
      achievements: [
        "Created 15+ interactive dashboards serving 200+ users",
        "Reduced report generation time from 8 hours to 15 minutes",
        "Implemented automated data refresh reducing manual errors by 95%",
        "Improved data accuracy through advanced validation rules"
      ],
      github: "https://github.com/saleemkallen",
      demo: null
    }
  ];

  const experience = [
    {
      role: "Data Engineer & Analytics Specialist",
      company: "Freelance/Consulting",
      period: "2022 - Present",
      achievements: [
        "Built end-to-end data pipelines processing 100GB+ daily",
        "Reduced data processing costs by 40% through cloud optimization",
        "Developed automated monitoring systems with 99.5% uptime",
        "Mentored 5+ junior data professionals"
      ]
    },
    {
      role: "Research Assistant - Data Analysis",
      company: "University Research Projects",
      period: "2020 - 2022",
      achievements: [
        "Conducted statistical analysis on environmental datasets",
        "Published research findings in peer-reviewed journals",
        "Developed R packages for specialized data analysis",
        "Collaborated with interdisciplinary research teams"
      ]
    }
  ];

  const certifications = [
    "Microsoft Azure Data Fundamentals",
    "Power BI Data Analyst Associate",
    "Google Data Analytics Professional Certificate",
    "AWS Cloud Practitioner"
  ];

  return (
    <div className="portfolio-container">
      {/* Navigation */}
      <nav className="navbar">
        <div className="nav-container">
          <div className="nav-logo">
            <h2>Muhammed Saleem Kallan</h2>
            <span>Data Engineer & Analytics Specialist</span>
          </div>
          <div className="nav-menu">
            <a href="#about" onClick={() => setActiveTab('about')}>About</a>
            <a href="#projects" onClick={() => setActiveTab('projects')}>Projects</a>
            <a href="#skills" onClick={() => setActiveTab('skills')}>Skills</a>
            <a href="#experience" onClick={() => setActiveTab('experience')}>Experience</a>
            <a href="#contact" onClick={() => setActiveTab('contact')}>Contact</a>
          </div>
          <div className="mobile-menu-toggle" onClick={() => setIsMenuOpen(!isMenuOpen)}>
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>
        {isMenuOpen && (
          <div className="mobile-menu">
            <a href="#about" onClick={() => { setActiveTab('about'); setIsMenuOpen(false); }}>About</a>
            <a href="#projects" onClick={() => { setActiveTab('projects'); setIsMenuOpen(false); }}>Projects</a>
            <a href="#skills" onClick={() => { setActiveTab('skills'); setIsMenuOpen(false); }}>Skills</a>
            <a href="#experience" onClick={() => { setActiveTab('experience'); setIsMenuOpen(false); }}>Experience</a>
            <a href="#contact" onClick={() => { setActiveTab('contact'); setIsMenuOpen(false); }}>Contact</a>
          </div>
        )}
      </nav>

      {/* Hero Section */}
      <section id="about" className="hero">
        <div className="hero-content">
          <div className="hero-text">
            <h1>Data Engineer & Analytics Specialist</h1>
            <p className="hero-subtitle">
              Transforming raw data into actionable insights through advanced analytics, 
              machine learning, and robust data engineering solutions.
            </p>
            <div className="hero-stats">
              <div className="stat">
                <h3>5+</h3>
                <p>Years Experience</p>
              </div>
              <div className="stat">
                <h3>50+</h3>
                <p>Data Projects</p>
              </div>
              <div className="stat">
                <h3>100GB+</h3>
                <p>Daily Data Processed</p>
              </div>
            </div>
            <div className="hero-buttons">
              <a href="#projects" className="btn btn-primary">View My Work</a>
              <a href="#contact" className="btn btn-secondary">Get In Touch</a>
            </div>
          </div>
          <div className="hero-image">
            <div className="profile-image">
              <img src="photo.jpg" alt="Muhammed Saleem Kallan" />
            </div>
          </div>
        </div>
      </section>

      {/* Projects Section */}
      <section id="projects" className="section">
        <div className="container">
          <h2 className="section-title">Data Engineering Projects</h2>
          <p className="section-subtitle">
            Showcasing my expertise in building scalable data solutions, 
            advanced analytics, and machine learning systems.
          </p>
          
          <div className="projects-grid">
            {projects.map((project) => (
              <div key={project.id} className="project-card">
                <div className="project-header">
                  <h3>{project.title}</h3>
                  <div className="project-tech">
                    {project.technologies.map((tech, index) => (
                      <span key={index} className="tech-tag">{tech}</span>
                    ))}
                  </div>
                </div>
                <p className="project-description">{project.description}</p>
                
                <div className="project-achievements">
                  <h4>Key Achievements:</h4>
                  <ul>
                    {project.achievements.map((achievement, index) => (
                      <li key={index}>{achievement}</li>
                    ))}
                  </ul>
                </div>
                
                <div className="project-links">
                  <a href={project.github} target="_blank" rel="noopener" className="btn btn-outline">
                    <i className="fab fa-github"></i> View Code
                  </a>
                  {project.demo && (
                    <a href={project.demo} target="_blank" rel="noopener" className="btn btn-outline">
                      <i className="fas fa-external-link-alt"></i> View Demo
                    </a>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Skills Section */}
      <section id="skills" className="section">
        <div className="container">
          <h2 className="section-title">Technical Skills & Expertise</h2>
          <p className="section-subtitle">
            Comprehensive technical skills across data engineering, analytics, 
            and cloud technologies.
          </p>
          
          <div className="skills-grid">
            <div className="skill-category">
              <h3><i className="fas fa-code"></i> Programming Languages</h3>
              <div className="skill-items">
                {skills.programming.map((skill, index) => (
                  <div key={index} className="skill-item">
                    <div className="skill-header">
                      <span className="skill-name">{skill.name}</span>
                      <span className="skill-level">{skill.category}</span>
                    </div>
                    <div className="skill-bar">
                      <div className="skill-progress" style={{'--skill-width': `${skill.level}%`} as React.CSSProperties}></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="skill-category">
              <h3><i className="fas fa-database"></i> Data Tools & Technologies</h3>
              <div className="skill-items">
                {skills.dataTools.map((skill, index) => (
                  <div key={index} className="skill-item">
                    <div className="skill-header">
                      <span className="skill-name">{skill.name}</span>
                      <span className="skill-level">{skill.category}</span>
                    </div>
                    <div className="skill-bar">
                      <div className="skill-progress" style={{'--skill-width': `${skill.level}%`} as React.CSSProperties}></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="skill-category">
              <h3><i className="fas fa-cloud"></i> Cloud & Infrastructure</h3>
              <div className="skill-items">
                {skills.cloud.map((skill, index) => (
                  <div key={index} className="skill-item">
                    <div className="skill-header">
                      <span className="skill-name">{skill.name}</span>
                      <span className="skill-level">{skill.category}</span>
                    </div>
                    <div className="skill-bar">
                      <div className="skill-progress" style={{'--skill-width': `${skill.level}%`} as React.CSSProperties}></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="skill-category">
              <h3><i className="fas fa-chart-line"></i> Analytics & Machine Learning</h3>
              <div className="skill-items">
                {skills.analytics.map((skill, index) => (
                  <div key={index} className="skill-item">
                    <div className="skill-header">
                      <span className="skill-name">{skill.name}</span>
                      <span className="skill-level">{skill.category}</span>
                    </div>
                    <div className="skill-bar">
                      <div className="skill-progress" style={{'--skill-width': `${skill.level}%`} as React.CSSProperties}></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="certifications">
            <h3>Certifications & Training</h3>
            <div className="cert-grid">
              {certifications.map((cert, index) => (
                <div key={index} className="cert-item">
                  <i className="fas fa-certificate"></i>
                  <span>{cert}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Experience Section */}
      <section id="experience" className="section">
        <div className="container">
          <h2 className="section-title">Professional Experience</h2>
          <p className="section-subtitle">
            Building data solutions and driving insights across various industries.
          </p>
          
          <div className="experience-timeline">
            {experience.map((exp, index) => (
              <div key={index} className="experience-item">
                <div className="experience-header">
                  <h3>{exp.role}</h3>
                  <div className="experience-meta">
                    <span className="company">{exp.company}</span>
                    <span className="period">{exp.period}</span>
                  </div>
                </div>
                <ul className="experience-achievements">
                  {exp.achievements.map((achievement, achIndex) => (
                    <li key={achIndex}>{achievement}</li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section id="contact" className="section contact-section">
        <div className="container">
          <h2 className="section-title">Let's Work Together</h2>
          <p className="section-subtitle">
            Ready to transform your data into actionable insights? 
            Let's discuss how I can help with your data engineering needs.
          </p>
          
          <div className="contact-content">
            <div className="contact-info">
              <div className="contact-item">
                <i className="fas fa-envelope"></i>
                <div>
                  <h4>Email</h4>
                  <p>muhammed.saleem@example.com</p>
                </div>
              </div>
              <div className="contact-item">
                <i className="fab fa-linkedin"></i>
                <div>
                  <h4>LinkedIn</h4>
                  <p>linkedin.com/in/muhammed-saleem-kallan</p>
                </div>
              </div>
              <div className="contact-item">
                <i className="fab fa-github"></i>
                <div>
                  <h4>GitHub</h4>
                  <p>github.com/saleemkallen</p>
                </div>
              </div>
            </div>
            
            <div className="contact-cta">
              <h3>Ready to Start Your Data Journey?</h3>
              <p>Let's discuss how I can help you build robust data solutions and unlock insights from your data.</p>
              <div className="cta-buttons">
                <a href="mailto:muhammed.saleem@example.com" className="btn btn-primary">
                  <i className="fas fa-envelope"></i> Send Email
                </a>
                <a href="https://www.linkedin.com/in/muhammed-saleem-kallan-499227127/" target="_blank" rel="noopener" className="btn btn-outline">
                  <i className="fab fa-linkedin"></i> Connect on LinkedIn
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            <p>&copy; 2024 Muhammed Saleem Kallan. All rights reserved.</p>
            <div className="footer-links">
              <a href="#about">About</a>
              <a href="#projects">Projects</a>
              <a href="#skills">Skills</a>
              <a href="#contact">Contact</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default DataEngineerPortfolio;
