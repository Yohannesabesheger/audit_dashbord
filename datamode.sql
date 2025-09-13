CREATE TABLE AuditTypes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL
);

create table AuditObject(
    id INT AUTO_INCREMENT PRIMARY KEY,
    object_name VARCHAR(255) NOT NULL,
    description TEXT,
    type_id INT,
    FOREIGN KEY (type_id) REFERENCES AuditTypes(id)
);
CREATE TABLE AuditPlan (
    plan_id INT AUTO_INCREMENT primary key,
    object_id INT, -- Link To Audit Object
    plan_year INT NOT NULL, -- Year of the audit plan
    audit_type_id INT, -- Link to AuditTypes
    planed_quarter ENUM('Q1', 'Q2', 'Q3', 'Q4') ,
    plan_status ENUM('Planned', 'In Progress', 'Completed', 'Overdue') NOT NULL,
    assigned_team VARCHAR(255),
    current_year BOOLEAN DEFAULT False,
    unique key(object_id,plan_year),
    foreign key (object_id) references AuditObject(id),
    FOREIGN KEY (audit_type_id) REFERENCES AuditTypes(id)
);



create table auditor(
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_title VARCHAR(255) NOT NULL,
    department VARCHAR(255) NOT NULL,
    expertise_area int,
    auditor_name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    foreign key ( expertise_area) references AuditTypes(id)   

);

create table auditees_organization(
    id INT AUTO_INCREMENT PRIMARY KEY,
    organization_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    contact_email VARCHAR(255) NOT NULL UNIQUE,
    contact_phone VARCHAR(20)
);

CREATE TABLE Engagements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_id INT, -- link to Audit
    start_date DATE,
    end_date DATE,
    quarter ENUM('Q1', 'Q2', 'Q3', 'Q4') NOT NULL,
    year INT NOT NULL,
    status ENUM('On-Track', 'Overdue', 'Completed') NOT NULL,
    status_details TEXT,
    phase ENUM('Pre-Engagement', 'Fieldwork', 'Reporting', 'Followup') NOT NULL,
    foreign key (plan_id) references AuditPlan(plan_id)
    
);


CREATE TABLE Responsiblity (
    responsibility_id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);

CREATE TABLE Assignment (
    performer_id INT NOT NULL,
    engagement_id INT NOT NULL,
    responsibility_id INT NOT NULL,
    PRIMARY KEY (performer_id, engagement_id, responsibility_id),
    FOREIGN KEY (engagement_id) REFERENCES Engagements(id),
    FOREIGN KEY (responsibility_id) REFERENCES Responsiblity(responsibility_id)
    -- performer_id can reference a Users or Teams table if available
);


CREATE TABLE Findings (
    finding_id INT AUTO_INCREMENT PRIMARY KEY,
    finding TEXT NOT NULL,
    criticality_level ENUM('High', 'Medium', 'Low') NOT NULL,
    audit_team VARCHAR(255),
    plan_id INT,
    auditee_organization VARCHAR(255),
    overdue_status BOOLEAN DEFAULT FALSE,
    rectification_status ENUM('Pending', 'In Progress', 'Completed') DEFAULT 'Pending',
    rectification_percent DECIMAL(5,2),
    assigned_team VARCHAR(255),
    rectificaton_description TEXT,
    follow_up_date DATE,
    auditor_comments TEXT,
    follower_id INT,
    foreign key (plan_id) references AuditPlan(plan_id)
);

create  table objectives(
    id INT AUTO_INCREMENT PRIMARY KEY,
    objective_name VARCHAR(255) NOT NULL,
    description TEXT,
    target_value DECIMAL(10,2) NOT NULL,
    achieved_value DECIMAL(10,2) DEFAULT 0,
    performance_percent DECIMAL(5,2) GENERATED ALWAYS AS ((achieved_value / target_value) * 100) STORED,
    assigned_to int,
    foreign key (assigned_to) references auditor(id)
);

create table sub_tasks(
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT NOT NULL,
    sub_task_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    status ENUM('Pending', 'In Progress', 'Completed', 'Overdue') NOT NULL,
    description TEXT,
    progress_percent DECIMAL(5,2),
    assigned_to VARCHAR(255),
    foreign key (parent_id) references objectives(id)
);

-- 
-- ===========================Reports and Performance Tracking===========================
-- this should show number
--   number of audit enagemnt on track, overdue, completed
--   number of audit plans completed vs planned
--   performance of audit plans vs targets
--   number of findings by criticality level
--   number of findings rectified vs pending

EngagementReports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    engagement_id INT NOT NULL,
    report_date DATE NOT NULL,
    report_type ENUM('Interim', 'Final', 'Follow-up') NOT NULL,
    summary TEXT,
    findings TEXT,
    recommendations TEXT,
    FOREIGN KEY (engagement_id) REFERENCES Engagements(id)
);

plan_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_id INT NOT NULL,
    target DECIMAL(10,2) NOT NULL,
    achieved DECIMAL(10,2) NOT NULL,
    performance_percent DECIMAL(5,2) GENERATED ALWAYS AS ((achieved / target) * 100) STORED,
    FOREIGN KEY (plan_id) REFERENCES AuditPlan(plan_id)
);



-- CREATE TABLE PlanPerformance (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     audit_engagement_id INT NOT NULL,
--     target DECIMAL(10,2) NOT NULL,
--     achieved DECIMAL(10,2) NOT NULL,
--     performance_percent DECIMAL(5,2) GENERATED ALWAYS AS ((achieved / target) * 100) STORED,
--     FOREIGN KEY (audit_engagement_id) REFERENCES Engagements(id)
);

-- CREATE TABLE Tasks (
--     task_id INT AUTO_INCREMENT PRIMARY KEY,
--     task_name VARCHAR(255) NOT NULL,
--     start_date DATE,
--     end_date DATE,
--     status ENUM('Pending', 'In Progress', 'Completed', 'Overdue') NOT NULL,
--     description TEXT,
--     progress_percent DECIMAL(5,2),
--     assigned_to VARCHAR(255),
--     audit_engagement_id INT,
--     FOREIGN KEY (audit_engagement_id) REFERENCES Engagements(id)
-- );

Task_performers (
    task_id INT NOT NULL,
    performer_id INT NOT NULL,
    PRIMARY KEY (task_id, performer_id),
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
    FOREIGN KEY (performer_id) REFERENCES Users(user_id) -- Uncomment and modify if
    -- performer_id can reference a Users or Teams table if available
);


CREATE TABLE Objectives (
    objective_id INT AUTO_INCREMENT PRIMARY KEY,
    objective_name VARCHAR(255) NOT NULL, -- e.g., Compliance, Vulnerability Reduction
    target_value DECIMAL(10,2) NOT NULL, -- e.g., 100% for compliance, 20% for vulnerability reduction
    achieved_value DECIMAL(10,2) DEFAULT 0,
    performance_percent DECIMAL(5,2) GENERATED ALWAYS AS ((achieved_value / target_value) * 100) STORED,
    description TEXT,
    assigned_team VARCHAR(255)
);

create table sub_task(
    sub_task_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT NOT NULL,
    sub_task_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    status ENUM('Pending', 'In Progress', 'Completed', 'Overdue') NOT NULL,
    description TEXT,
    progress_percent DECIMAL(5,2),
    assigned_to VARCHAR(255),
    
);





--OKR parts objectives and key results with cascading options where the childe objective is inheritiv from the parenet key results
CREATE TABLE Objectives_level_one (
    objective_id INT AUTO_INCREMENT PRIMARY KEY,
    objective_name VARCHAR(255) NOT NULL,
    objective_weight DECIMAL(5,2) NOT NULL,
    target_value DECIMAL(10,2) NOT NULL,




    target_value DECIMAL(10,2) NOT NULL,
    achieved_value DECIMAL(10,2) DEFAULT 0,
    performance_percent DECIMAL(5,2) GENERATED ALWAYS AS ((achieved_value / target_value) * 100) STORED,
    description TEXT,
    assigned_team VARCHAR(255),
    FOREIGN KEY (parent_objective_id) REFERENCES OKR_Objectives(objective_id) ON DELETE CASCADE
);
CREATE TABLE Key_Results_level_one (
    key_result_id INT AUTO_INCREMENT PRIMARY KEY,
    objective_id INT NOT NULL,
    key_result_name VARCHAR(255) NOT NULL,
    target_value DECIMAL(10,2) NOT NULL,
    achieved_value DECIMAL(10,2) DEFAULT 0,
    performance_percent DECIMAL(5,2) GENERATED ALWAYS AS ((achieved_value / target_value) * 100) STORED,
    description TEXT,
    assigned_team VARCHAR(255),
    FOREIGN KEY (objective_id) REFERENCES Objectives_level_one(objective_id) ON DELETE CASCADE
);
CREATE TABLE Objectives_level_two (
    objective_id INT AUTO_INCREMENT PRIMARY KEY,
    objective_name VARCHAR(255) NOT NULL,
    target_value DECIMAL(10,2) NOT NULL,
    achieved_value DECIMAL(10,2) DEFAULT 0,
    performance_percent DECIMAL(5,2) GENERATED ALWAYS AS ((achieved_value / target_value) * 100) STORED,
    description TEXT,
    assigned_team VARCHAR(255),
    FOREIGN KEY (parent_objective_id) REFERENCES Objectives_level_one(objective_id) ON DELETE CASCADE
);
CREATE TABLE Key_Results_level_two (
    key_result_id INT AUTO_INCREMENT PRIMARY KEY,
    objective_id INT NOT NULL,              


-- -- ===========================Sample Data Insertion===========================
--- ===============================Audit Object ================================
INSERT INTO AuditObject (object_name, description, type_id) VALUES
('Identity and Access Management (IAM)', 'Audit IAM policies, roles, and access controls', 3),
('AML System and Project', 'Review AML system functionalities and project implementations', 3),
('Fraud Management System', 'Assess fraud detection and management controls', 3),
('IT Resource Provisioning (Compute, Storage, Network)', 'Audit resource allocation and provisioning processes', 3),
('Database Administration for Mission Critical Systems', 'Review DB admin practices for critical systems', 3),
('SOC Monitoring & Incident Response Management', 'Assess SOC monitoring and incident handling', 3),
('SWIFT CSP Compliance', 'Evaluate SWIFT CSP compliance requirements', 3),
('Webserver and Web Application (JBOSS, WebLogic, Middleware)', 'Audit web server and middleware management', 3),
('Souq Pass-Payment Gateway and Inventory', 'Review payment gateway and inventory systems', 3),
('Cooprol (Payroll System)', 'Audit payroll system and compliance', 3),
('Michu Mizan (IFB)', 'Review IFB system and transactions', 3),
('Endpoint Security, Active Directory Controls, Service Availability (HO + Branch)', 'Audit endpoint security and AD controls', 3),
('API Integrations, Payment Gateway, Security & Lifecycle Management', 'Review APIs, security, and lifecycle', 3),
('Core Banking System', 'Audit core banking processes and IT controls', 3),
('Network Administration (LAN/WAN/Internet Access)', 'Audit network administration and access', 3),
('Windows Server & Active Directory Management', 'Review Windows servers and AD management', 3),
('Enterprise Resource Planning System (ERP)', 'Audit ERP functionalities and controls', 3),
('Michu Platforms', 'Review Michu platform operations and IT security', 3),
('Software Development, Automation & SDLC Quality Management', 'Audit development, automation, and SDLC practices', 3),
('Diaspora Banking Customer Onboarding', 'Review onboarding process for diaspora customers', 3),
('Omni-channel Delivery Platforms (Web, Mobile)', 'Audit web and mobile delivery platforms', 3),
('Switching System (Cards, POS, ATMs, Terminals, Mastercard Integration)', 'Audit card and switching systems', 3),
('Network Security & Vulnerability Assessment', 'Conduct network security and vulnerability assessment', 3),
('Application Security & Vulnerability Testing', 'Audit application security and perform vulnerability testing', 3),
('FIS Project', 'Review FIS project IT controls and progress', 3),
('Backup, Restoration Testing, and Archive Management System', 'Audit backup, restoration, and archiving processes', 3),
('CTS (Cheque and RTGS)', 'Audit cheque and RTGS systems', 3),
('Internal Dev Apps', 'Audit internal development applications', 3),
('Coop Remit', 'Audit Coop Remit platform', 3),
('VSLA-Village Saving', 'Audit village saving systems', 3),
('Coop Ambitions', 'Audit Coop Ambitions IT systems', 3),
('Saco Link', 'Audit Saco Link systems', 3),
('Furtu', 'Audit Furtu platform', 3),
('Farm Pass', 'Audit Farm Pass IT systems', 3),
('Enterprise Architecture', 'Review enterprise architecture practices', 3),
('Enterprise Data Governance & Information Lifecycle Management', 'Audit data governance and lifecycle management', 3),
('SeaFile (GL and PL Repository)', 'Audit GL/PL repository systems', 3),
('Burning OKR', 'Review OKR system', 3),
('Kannel (SMS Gateway)', 'Audit SMS gateway and integrations', 3),
('Regulatory Compliance, Fraud Prevention & Readiness', 'Audit IT regulatory compliance and fraud prevention', 3),
('Share Management System', 'Audit share management IT systems', 3),
('IT Asset Management (Inventory & Lifecycle)', 'Audit IT asset management processes', 3),
('HR Outsourcing System', 'Audit HR outsourcing IT systems', 3),
('Debo Crowd Funding', 'Audit Debo crowdfunding platform', 3),
('Business Intelligence, MIS, ETL & Reporting Systems', 'Audit BI, MIS, ETL, and reporting systems', 3),
('Third Party/Vendor Risk Management & SLA Enforcement', 'Audit third-party risk and SLA compliance', 3),
('Smart-Branch', 'Audit Smart-Branch systems', 3),
('COOPLD (Loan Document Repository)', 'Audit loan document repository systems', 3),
('Coop-Engage-Onboarding', 'Audit onboarding platform', 3),
('Data Center Infrastructure (Facilities & Equipment)', 'Audit data center facilities and equipment', 3),
('Change Management & Release Enablement Practice', 'Audit change management and release processes', 3),
('Linux/Unix Operating Systems (Server Management)', 'Audit Linux/Unix server management', 3),
('Enterprise Cybersecurity, IT Disaster Recovery & Business Continuity Management', 'Audit enterprise cybersecurity, disaster recovery and BCP', 3),
('Digital Transformation Strategy & Value Realization Office (VRO)', 'Audit digital transformation and VRO initiatives', 3),
('COOP Stream', 'Audit COOP Stream platform', 3),
('Innovation & Digital Product Development (Sandbox, MVPs, Time-to-Market)', 'Audit innovation and product development processes', 3),
('Project Management Practices and Deliverables', 'Audit project management practices', 3),
('IT Service Management (ITSM) & Service Desk Operations', 'Audit ITSM and service desk operations', 3),
('IT Governance, Enterprise Architecture & Strategic Performance Alignment', 'Audit IT governance and strategic alignment', 3);


-- ====================================Insert Sample Audit  Object====================
INSERT INTO AuditPlan (object_id, plan_year, audit_type_id, planed_quarter, plan_status, assigned_team, current_year) VALUES
(1, 2026, 3, 'Q1', 'Planned', 'Team A', TRUE),
(2, 2026, 3, 'Q2', 'Planned', 'Team B', TRUE),
(3, 2026, 3, 'Q3', 'Planned', 'IT Audit Team', TRUE),
(4, 2026, 3, 'Q4', 'Planned', 'Team C', TRUE),
(5, 2026, 3, 'Q1', 'Planned', 'DBA Team', TRUE),
(6, 2026, 3, 'Q2', 'Planned', 'SOC Team', TRUE),
(7, 2026, 3, 'Q3', 'Planned', 'IT Compliance Team', TRUE),
(8, 2026, 3, 'Q4', 'Planned', 'WebOps Team', TRUE),
(9, 2026, 3, 'Q1', 'Planned', 'Payment Team', TRUE),
(10, 2026, 3, 'Q2', 'Planned', 'HR Team', TRUE),
(11, 2026, 3, 'Q3', 'Planned', 'IFB Team', TRUE),
(12, 2026, 3, 'Q4', 'Planned', 'Endpoint Security Team', TRUE),
(13, 2026, 3, 'Q1', 'Planned', 'API & Security Team', TRUE),
(14, 2026, 3, 'Q2', 'Planned', 'Core Banking Team', TRUE),
(15, 2026, 3, 'Q3', 'Planned', 'Network Team', TRUE),
(16, 2026, 3, 'Q4', 'Planned', 'Windows/AD Team', TRUE),
(17, 2026, 3, 'Q1', 'Planned', 'ERP Team', TRUE),
(18, 2026, 3, 'Q2', 'Planned', 'Michu Team', TRUE),
(19, 2026, 3, 'Q3', 'Planned', 'SDLC Team', TRUE),
(20, 2026, 3, 'Q4', 'Planned', 'Onboarding Team', TRUE),
(21, 2026, 3, 'Q1', 'Planned', 'Omni-channel Team', TRUE),
(22, 2026, 3, 'Q2', 'Planned', 'Switching Team', TRUE),
(23, 2026, 3, 'Q3', 'Planned', 'Network Security Team', TRUE),
(24, 2026, 3, 'Q4', 'Planned', 'App Security Team', TRUE),
(25, 2026, 3, 'Q1', 'Planned', 'FIS Project Team', TRUE),
(26, 2026, 3, 'Q2', 'Planned', 'Backup/Archive Team', TRUE),
(27, 2026, 3, 'Q3', 'Planned', 'CTS Team', TRUE),
(28, 2026, 3, 'Q4', 'Planned', 'Internal Dev Team', TRUE),
(29, 2026, 3, 'Q1', 'Planned', 'Coop Remit Team', TRUE),
(30, 2026, 3, 'Q2', 'Planned', 'VSLA Team', TRUE),
(31, 2026, 3, 'Q3', 'Planned', 'Coop Ambitions Team', FALSE),
(32, 2026, 3, 'Q4', 'Planned', 'Saco Link Team', FALSE),
(33, 2026, 3, 'Q1', 'Planned', 'Furtu Team', FALSE),
(34, 2026, 3, 'Q2', 'Planned', 'Farm Pass Team', FALSE),
(35, 2026, 3, 'Q3', 'Planned', 'Enterprise Architecture Team', FALSE),
(36, 2026, 3, 'Q4', 'Planned', 'Data Governance Team', FALSE),
(37, 2026, 3, 'Q1', 'Planned', 'SeaFile Team', FALSE),
(38, 2026, 3, 'Q2', 'Planned', 'OKR Team', FALSE),
(39, 2026, 3, 'Q3', 'Planned', 'Kannel Team', FALSE),
(40, 2026, 3, 'Q4', 'Planned', 'Regulatory Team', FALSE),
(41, 2026, 3, 'Q1', 'Planned', 'Share Management Team', FALSE),
(42, 2026, 3, 'Q2', 'Planned', 'IT Asset Management Team', FALSE),
(43, 2026, 3, 'Q3', 'Planned', 'HR Outsourcing Team', FALSE),
(44, 2026, 3, 'Q4', 'Planned', 'Debo Team', FALSE),
(45, 2026, 3, 'Q1', 'Planned', 'BI & MIS Team', FALSE),
(46, 2026, 3, 'Q2', 'Planned', 'Third Party Risk Team', FALSE),
(47, 2026, 3, 'Q3', 'Planned', 'Smart-Branch Team', FALSE),
(48, 2026, 3, 'Q4', 'Planned', 'COOPLD Team', FALSE),
(49, 2026, 3, 'Q1', 'Planned', 'Coop Engage Team', FALSE),
(50, 2026, 3, 'Q2', 'Planned', 'Data Center Team', FALSE),
(51, 2026, 3, 'Q3', 'Planned', 'Change Management Team', FALSE),
(52, 2026, 3, 'Q4', 'Planned', 'Linux/Unix Team', FALSE),
(53, 2026, 3, 'Q1', 'Planned', 'Cybersecurity & BCP Team', FALSE),
(54, 2026, 3, 'Q2', 'Planned', 'Digital Transformation Team', FALSE),
(55, 2026, 3, 'Q3', 'Planned', 'COOP Stream Team', FALSE),
(56, 2026, 3, 'Q4', 'Planned', 'Innovation Team', FALSE),
(57, 2026, 3, 'Q1', 'Planned', 'Project Management Team', FALSE),
(58, 2026, 3, 'Q2', 'Planned', 'ITSM & Service Desk Team', FALSE),
(59, 2026, 3, 'Q3', 'Planned', 'IT Governance Team', FALSE);

-- ====================================Insert Sample ====================

-- =============================================Engagement======================
INSERT INTO Engagements (plan_id, start_date, end_date, quarter, year, status, status_details, phase) VALUES
(1, '2026-01-05', '2026-01-20', 'Q1', 2026, 'On-Track', 'Engagement started, fieldwork pending', 'Pre-Engagement'),
(2, '2026-04-01', '2026-04-15', 'Q2', 2026, 'Overdue', 'Initial review delayed', 'Pre-Engagement'),
(3, '2026-07-01', '2026-07-20', 'Q3', 2026, 'On-Track', 'Fieldwork ongoing', 'Fieldwork'),
(4, '2026-10-01', '2026-10-15', 'Q4', 2026, 'On-Track', 'Engagement preparation in progress', 'Pre-Engagement'),
(5, '2026-01-10', '2026-01-25', 'Q1', 2026, 'Overdue', 'Pending kickoff meeting', 'Pre-Engagement'),
(6, '2026-04-05', '2026-04-20', 'Q2', 2026, 'On-Track', 'Fieldwork started', 'Fieldwork'),
(7, '2026-07-05', '2026-07-22', 'Q3', 2026, 'Overdue', 'Delays in data collection', 'Fieldwork'),
(8, '2026-10-05', '2026-10-18', 'Q4', 2026, 'On-Track', 'Follow-up pending', 'Followup'),
(9, '2026-01-15', '2026-01-30', 'Q1', 2026, 'On-Track', 'Pre-engagement meeting completed', 'Pre-Engagement'),
(10, '2026-04-10', '2026-04-25', 'Q2', 2026, 'Overdue', 'Documentation not submitted', 'Reporting');
-- ================================================= Auditees Orginizations======================

INSERT INTO auditees_organization (organization_name, contact_person, contact_email, contact_phone) VALUES
('Infrastructure', 'Eng. Bekele Desta', 'bekele.desta@bank.com', '+251911100001'),
('Cyber Security', 'Selamawit Tadesse', 'selamawit.t@bank.com', '+251911100002'),
('Data Management', 'Mulugeta Kassa', 'mulugeta.k@bank.com', '+251911100003'),
('Core System and Enterprise Applications', 'Yonas Alemu', 'yonas.alemu@bank.com', '+251911100004'),
('IT Risk Management', 'Ashenafi Girm', 'ashenafi.g@bank.com', '+251911100005'),
('Digital Product Innovations', 'Addisu Akmsur', 'addisu.a@bank.com', '+251911100006');

-- Audit Assigmnet
-- Engagement 1
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(1, 1, 2),
(2, 1, 2);

-- Engagement 2
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(3, 2, 2),
(4, 2, 2);

-- Engagement 3
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(5, 3, 2),
(6, 3, 2);

-- Engagement 4
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(7, 4, 2),
(8, 4, 2);

-- Engagement 5
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(9, 5, 2),
(1, 5, 2);

-- Engagement 6
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(2, 6, 2),
(3, 6, 2);

-- Engagement 7
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(4, 7, 2),
(5, 7, 2);

-- Engagement 8
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(6, 8, 2),
(7, 8, 2);

-- Engagement 9
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(8, 9, 2),
(9, 9, 2);

-- Engagement 10
INSERT INTO Assignment (performer_id, engagement_id, responsibility_id) VALUES
(1, 10, 2),
(2, 10, 2);
-- ========================Adutors================================
INSERT INTO auditor (job_title, department, expertise_area, auditor_name, contact_info, email, phone) VALUES
('Principal IT Auditor', 'IT Audit', 3, 'Gemechu Keneni', 'gemechu.k@example.com', 'gemechu.k@example.com', '+251911000001'),
('Principal IT Auditor', 'IT Audit', 3, 'Addisu Akmsur', 'addisu.a@example.com', 'addisu.a@example.com', '+251911000002'),
('Senior IT Auditor', 'IT Audit', 3, 'Ashenafi Girm', 'ashenafi.g@example.com', 'ashenafi.g@example.com', '+251911000003'),
('Senior IT Auditor', 'IT Audit', 3, 'Solomon Zerhun', 'solomon.z@example.com', 'solomon.z@example.com', '+251911000004'),
('Officer / IT Auditor', 'IT Audit', 3, 'Natnael Tsegaye', 'natnael.t@example.com', 'natnael.t@example.com', '+251911000005'),
('Officer / IT Auditor', 'IT Audit', 3, 'Tadele', 'tadele@example.com', 'tadele@example.com', '+251911000006'),
('Officer / IT Auditor', 'IT Audit', 3, 'Workineh Negasa', 'workineh.n@example.com', 'workineh.n@example.com', '+251911000007'),
('IT Auditor', 'IT Audit', 3, 'Fikadu Alemu', 'fikadu.a@example.com', 'fikadu.a@example.com', '+251911000008'),
('IT Auditor', 'IT Audit', 3, 'Yohannes Mitike', 'yohannes.m@example.com', 'yohannes.m@example.com', '+251911000009');


-- ===============================Audit Plans========================

INSERT INTO Responsiblity (description) VALUES
('Team Leader'),
('Member');




-- =======================Insert sample Findings========================

-- Engagement 3
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('Weak firewall configuration', 'High', 'Network Security Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'Network Security Team', 'Update firewall rules', '2026-08-01', 'Firewall outdated', 1),
('Unpatched server vulnerabilities', 'Medium', 'IT Security Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Apply security patches', '2026-08-02', 'Servers missing updates', 2),
('Incomplete network access logs', 'Low', 'Network Security Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'Network Security Team', 'Collect and store logs', '2026-08-03', 'Logs not complete', 3),
('Unauthorized device connection', 'High', 'IT Audit Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Audit Team', 'Restrict unauthorized devices', '2026-08-04', 'Devices connected without approval', 1),
('Network segmentation gaps', 'Medium', 'Network Security Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'Network Security Team', 'Implement proper segmentation', '2026-08-05', 'Segmentation gaps exist', 2),
('Weak VPN configuration', 'Low', 'IT Security Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Review VPN settings', '2026-08-06', 'VPN settings not compliant', 3),
('Firewall rule exceptions', 'High', 'Network Security Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'Network Security Team', 'Review and remove exceptions', '2026-08-07', 'Too many exceptions', 1),
('Delayed incident response', 'Medium', 'SOC Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'SOC Team', 'Improve response time', '2026-08-08', 'Incidents not addressed timely', 2),
('Network monitoring gaps', 'Low', 'SOC Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'SOC Team', 'Enhance monitoring', '2026-08-09', 'Monitoring incomplete', 3),
('Configuration management missing', 'Medium', 'Network Security Team', 3, 'Bank X Branch 1', FALSE, 'Pending', 0, 'Network Security Team', 'Track configuration changes', '2026-08-10', 'Missing CM documentation', 1);

-- Engagement 4
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('Incomplete payroll records', 'High', 'HR Audit Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Ensure payroll records are accurate', '2026-10-15', 'Records missing for some employees', 1),
('Payroll approval missing', 'Medium', 'HR Audit Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Obtain approval for payroll', '2026-10-16', 'Approval workflow skipped', 2),
('Overtime calculation errors', 'Low', 'HR Audit Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Verify overtime calculations', '2026-10-17', 'Miscalculations detected', 3),
('Payroll system access not restricted', 'High', 'HR Audit Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Restrict access', '2026-10-18', 'Unauthorized access possible', 1),
('Missing backup of payroll data', 'Medium', 'Backup Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Backup Team', 'Ensure payroll backups', '2026-10-19', 'Backups not performed', 2),
('Incorrect tax deduction', 'Low', 'HR Audit Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Correct tax deductions', '2026-10-20', 'Errors in tax calculations', 3),
('Inactive employees still paid', 'High', 'HR Audit Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Stop payments to inactive employees', '2026-10-21', 'Payments processed incorrectly', 1),
('Payroll reconciliation delayed', 'Medium', 'Finance Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Finance Team', 'Reconcile payroll accounts', '2026-10-22', 'Reconciliation backlog exists', 2),
('Payroll report not submitted', 'Low', 'HR Audit Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Submit reports timely', '2026-10-23', 'Report missing for last month', 3),
('System alerts ignored', 'Medium', 'IT Security Team', 4, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Security Team', 'Investigate system alerts', '2026-10-24', 'Alerts not addressed', 1);

-- ======================================================Engagement 5
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('Endpoint antivirus missing', 'High', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Install antivirus on all endpoints', '2026-02-20', 'Endpoints unprotected', 1),
('Unencrypted laptops', 'Medium', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Encrypt all laptops', '2026-02-21', 'Data exposure risk', 2),
('Inactive accounts not removed', 'Low', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Disable inactive accounts', '2026-02-22', 'Accounts still active', 3),
('Outdated software versions', 'High', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Update software', '2026-02-23', 'Several endpoints outdated', 1),
('Missing endpoint policies', 'Medium', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Implement policies', '2026-02-24', 'No formal policies in place', 2),
('Unauthorized device connection', 'Low', 'IT Audit Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Audit Team', 'Restrict device connection', '2026-02-25', 'Devices connected without approval', 3),
('Endpoint monitoring gaps', 'High', 'SOC Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'SOC Team', 'Monitor endpoints', '2026-02-26', 'Monitoring missing', 1),
('Pending endpoint remediation', 'Medium', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Remediate issues', '2026-02-27', 'Pending remediation', 2),
('Endpoint configuration inconsistent', 'Low', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Standardize configuration', '2026-02-28', 'Configurations inconsistent', 3),
('Antivirus updates not applied', 'Medium', 'IT Security Team', 5, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Apply antivirus updates', '2026-03-01', 'Updates missing', 1);


-- Engagement 6
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('Delayed SWIFT transaction reconciliation', 'High', 'Financial Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Perform timely reconciliation', '2026-05-18', 'Backlog of unreconciled transactions', 1),
('SWIFT access controls weak', 'Medium', 'IT Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Audit Team', 'Enforce access control', '2026-05-19', 'Unauthorized users detected', 2),
('SWIFT audit logs incomplete', 'Low', 'Financial Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Collect and review logs', '2026-05-20', 'Some logs missing', 3),
('Pending exception approvals', 'High', 'Financial Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Resolve exceptions', '2026-05-21', 'Exceptions pending', 1),
('SWIFT configuration gaps', 'Medium', 'IT Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Audit Team', 'Review configuration', '2026-05-22', 'Settings not compliant', 2),
('Delayed staff training', 'Low', 'HR Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'HR Audit Team', 'Train staff', '2026-05-23', 'Training pending', 3),
('SWIFT transaction errors', 'High', 'Financial Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Correct errors', '2026-05-24', 'Errors detected', 1),
('Unauthorized user approvals', 'Medium', 'IT Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Audit Team', 'Review user approvals', '2026-05-25', 'Unauthorized approvals observed', 2),
('Incomplete SWIFT documentation', 'Low', 'Financial Audit Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Complete documentation', '2026-05-26', 'Documents missing', 3),
('SWIFT system monitoring gaps', 'Medium', 'IT Security Team', 6, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Security Team', 'Enhance monitoring', '2026-05-27', 'Monitoring incomplete', 1);

-- Engagement 7
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('Insufficient API security controls', 'High', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Implement authentication and logging', '2026-08-05', 'Some APIs exposed', 1),
('APIs missing encryption', 'Medium', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Encrypt all API communications', '2026-08-06', 'Sensitive data not encrypted', 2),
('API access not logged', 'Low', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Enable audit logs', '2026-08-07', 'Logs missing', 3),
('Unauthorized API users', 'High', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Restrict access', '2026-08-08', 'Unauthorized users found', 1),
('API performance issues', 'Medium', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Resolve performance bottlenecks', '2026-08-09', 'Slower than expected', 2),
('Incomplete API documentation', 'Low', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Document all APIs', '2026-08-10', 'Documentation gaps', 3),
('APIs without testing', 'High', 'QA Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'QA Audit Team', 'Perform testing', '2026-08-11', 'No testing done', 1),
('Pending API updates', 'Medium', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Apply updates', '2026-08-12', 'Updates delayed', 2),
('API error handling missing', 'Low', 'API Audit Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'API Audit Team', 'Implement error handling', '2026-08-13', 'Error handling absent', 3),
('APIs exposed externally', 'Medium', 'IT Security Team', 7, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Restrict external exposure', '2026-08-14', 'External exposure detected', 1);

-- Engagement 8
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('Incomplete core banking access logs', 'High', 'Core Banking Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Core Banking Team', 'Review logs for all users', '2026-10-20', 'Access logs missing', 1),
('Unauthorized core banking access', 'Medium', 'Core Banking Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Core Banking Team', 'Restrict access', '2026-10-21', 'Unauthorized access detected', 2),
('Core banking backups missing', 'Low', 'Backup Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Backup Team', 'Ensure backups performed', '2026-10-22', 'Backups not done', 3),
('Core banking transaction errors', 'High', 'Financial Audit Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Correct errors', '2026-10-23', 'Transactions misposted', 1),
('Core banking configuration gaps', 'Medium', 'IT Audit Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Audit Team', 'Review configuration', '2026-10-24', 'Configuration not compliant', 2),
('Pending reconciliation', 'Low', 'Financial Audit Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Reconcile accounts', '2026-10-25', 'Reconciliation not done', 3),
('Inactive accounts still active', 'High', 'Core Banking Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Core Banking Team', 'Disable inactive accounts', '2026-10-26', 'Accounts active incorrectly', 1),
('Audit trail incomplete', 'Medium', 'Core Banking Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Core Banking Team', 'Complete audit trail', '2026-10-27', 'Incomplete audit trail', 2),
('User access review pending', 'Low', 'Core Banking Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Core Banking Team', 'Perform user access review', '2026-10-28', 'Review not done', 3),
('Core banking system monitoring gaps', 'Medium', 'IT Security Team', 8, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Security Team', 'Improve monitoring', '2026-10-29', 'Monitoring incomplete', 1);

-- Engagement 9
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('ERP data inconsistencies', 'High', 'ERP Audit Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'ERP Audit Team', 'Validate and correct ERP data', '2026-02-25', 'Discrepancies found', 1),
('ERP user access excessive', 'Medium', 'ERP Audit Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'ERP Audit Team', 'Restrict user access', '2026-02-26', 'Excess access detected', 2),
('ERP system configuration gaps', 'Low', 'ERP Audit Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'ERP Audit Team', 'Review configuration', '2026-02-27', 'Configuration not compliant', 3),
('ERP workflow delays', 'High', 'ERP Audit Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'ERP Audit Team', 'Improve workflow', '2026-02-28', 'Delays in process', 1),
('ERP reporting errors', 'Medium', 'ERP Audit Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'ERP Audit Team', 'Correct report data', '2026-03-01', 'Errors in reports', 2),
('ERP backup missing', 'Low', 'Backup Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'Backup Team', 'Ensure backups', '2026-03-02', 'Backup missing', 3),
('ERP endpoint gaps', 'High', 'IT Security Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Secure endpoints', '2026-03-03', 'Endpoints unsecured', 1),
('ERP patch management delayed', 'Medium', 'IT Security Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'IT Security Team', 'Apply patches', '2026-03-04', 'Patches delayed', 2),
('ERP training incomplete', 'Low', 'HR Audit Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'HR Audit Team', 'Conduct training', '2026-03-05', 'Training not done', 3),
('ERP reconciliation gaps', 'Medium', 'Finance Team', 9, 'Bank X Branch 1', FALSE, 'Pending', 0, 'Finance Team', 'Reconcile accounts', '2026-03-06', 'Reconciliation incomplete', 1);

-- Engagement 10
INSERT INTO Findings (finding, criticality_level, audit_team, plan_id, auditee_organization, overdue_status, rectification_status, rectification_percent, assigned_team, rectificaton_description, follow_up_date, auditor_comments, follower_id)
VALUES
('Incomplete switch configuration', 'High', 'Network Audit Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Network Audit Team', 'Complete switch configuration', '2026-06-15', 'Configuration incomplete', 1),
('POS transaction errors', 'Medium', 'Financial Audit Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Financial Audit Team', 'Correct POS transactions', '2026-06-16', 'Errors in transactions', 2),
('ATM connectivity issues', 'Low', 'IT Audit Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Audit Team', 'Fix connectivity', '2026-06-17', 'ATMs not connected', 3),
('Card issuance delays', 'High', 'Card Operations Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Card Operations Team', 'Accelerate issuance', '2026-06-18', 'Delays in issuance', 1),
('Switching system monitoring gaps', 'Medium', 'IT Security Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Security Team', 'Enhance monitoring', '2026-06-19', 'Monitoring incomplete', 2),
('Unauthorized terminal access', 'Low', 'Network Audit Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Network Audit Team', 'Restrict access', '2026-06-20', 'Unauthorized access detected', 3),
('Pending software updates', 'High', 'IT Security Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Security Team', 'Apply updates', '2026-06-21', 'Updates pending', 1),
('Switch reconciliation errors', 'Medium', 'Finance Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Finance Team', 'Correct reconciliation', '2026-06-22', 'Errors found', 2),
('Switch system documentation missing', 'Low', 'IT Audit Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'IT Audit Team', 'Document system', '2026-06-23', 'Documentation missing', 3),
('Switch endpoint gaps', 'Medium', 'Network Audit Team', 10, 'Bank Y Branch 2', FALSE, 'Pending', 0, 'Network Audit Team', 'Secure endpoints', '2026-06-24', 'Endpoints unsecured', 1);


-- ===============================Select Statments ========================
-----Engagement dEtails
--=============================================================
--============================Overal plan performnce=========================
-- Current Year Plan Performance Overal performance
 SELECT 
    ap.plan_year,
    COUNT(DISTINCT ap.plan_id) AS total_plans,
    SUM(CASE WHEN ap.plan_status = 'Completed' THEN 1 ELSE 0 END) AS completed_plans,
    ROUND(SUM(CASE WHEN ap.plan_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(DISTINCT ap.plan_id) * 100, 2) AS plan_completion_rate,
    SUM(CASE WHEN ap.plan_status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_plans,
    SUM(CASE WHEN ap.plan_status = 'In Progress' THEN 1 ELSE 0 END) AS ongoing_plans
FROM AuditPlan ap
WHERE ap.current_year = TRUE
GROUP BY ap.plan_year
ORDER BY ap.plan_year DESC;


-- ======================================Quarterly grouped Plan Performance=========================
SELECT 
    ap.plan_year,
    ap.planed_quarter,
    COUNT(DISTINCT ap.plan_id) AS total_plans,
    SUM(CASE WHEN ap.plan_status = 'Completed' THEN 1 ELSE 0 END) AS completed_plans,
    SUM(CASE WHEN ap.plan_status = 'In Progress' THEN 1 ELSE 0 END) AS ongoing_plans,
    SUM(CASE WHEN ap.plan_status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_plans,
    ROUND(
        SUM(CASE WHEN ap.plan_status = 'Completed' THEN 1 ELSE 0 END) / 
        COUNT(DISTINCT ap.plan_id) * 100, 2
    ) AS completion_rate
FROM AuditPlan ap
WHERE ap.current_year = TRUE
GROUP BY ap.plan_year, ap.planed_quarter
ORDER BY ap.plan_year DESC, 
         FIELD(ap.planed_quarter, 'Q1','Q2','Q3','Q4');
-- ====================================3. Findings Rectification Performance (Current-Year Plans Only)=========================
SELECT 
    ap.plan_id,
    ao.object_name,
    COUNT(f.finding_id) AS total_findings,
    SUM(CASE WHEN f.rectification_status = 'Completed' THEN 1 ELSE 0 END) AS rectified_findings,
    ROUND(SUM(CASE WHEN f.rectification_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(f.finding_id) * 100, 2) AS rectification_rate,
    SUM(CASE WHEN f.overdue_status = TRUE THEN 1 ELSE 0 END) AS overdue_findings
FROM Findings f
JOIN AuditPlan ap ON f.plan_id = ap.plan_id
JOIN AuditObject ao ON ap.object_id = ao.id
WHERE ap.current_year = TRUE
GROUP BY ap.plan_id, ao.object_name
ORDER BY ap.plan_id;
-- ====================================4. Findings by Criticality Level (Current-Year Plans Only)=========================

