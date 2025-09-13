from django.db import models

# 1. Audit Types
class AuditType(models.Model):
    type_name = models.CharField(max_length=100)

    def __str__(self):
        return self.type_name


# 2. Audit Object
class AuditObject(models.Model):
    object_name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    type = models.ForeignKey(AuditType, on_delete=models.CASCADE)

    def __str__(self):
        return self.object_name


# 3. Audit Plan
class AuditPlan(models.Model):
    QUARTERS = [('Q1','Q1'), ('Q2','Q2'), ('Q3','Q3'), ('Q4','Q4')]
    STATUS_CHOICES = [('Planned','Planned'), ('In Progress','In Progress'), ('Completed','Completed'), ('Overdue','Overdue')]

    object = models.ForeignKey(AuditObject, on_delete=models.CASCADE)
    plan_year = models.IntegerField()
    audit_type = models.ForeignKey(AuditType, on_delete=models.CASCADE)
    planed_quarter = models.CharField(max_length=2, choices=QUARTERS, blank=True, null=True)
    plan_status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    assigned_team = models.CharField(max_length=255, blank=True, null=True)
    current_year = models.BooleanField(default=False)

    class Meta:
        unique_together = ('object', 'plan_year')

    def __str__(self):
        return f"{self.object} - {self.plan_year}"


# 4. Auditor
class Auditor(models.Model):
    job_title = models.CharField(max_length=255)
    department = models.CharField(max_length=255)
    expertise_area = models.ForeignKey(AuditType, on_delete=models.CASCADE)
    auditor_name = models.CharField(max_length=255)
    contact_info = models.CharField(max_length=255, blank=True, null=True)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return self.auditor_name


# 5. Auditee Organization
class AuditeeOrganization(models.Model):
    organization_name = models.CharField(max_length=255)
    contact_person = models.CharField(max_length=255, blank=True, null=True)
    contact_email = models.EmailField(unique=True)
    contact_phone = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return self.organization_name


# 6. Engagement
class Engagement(models.Model):
    QUARTERS = [('Q1','Quarter 1'), ('Q2','Quarter 2'), ('Q3','Quarter 2'), ('Q4','Quarter 4')]
    STATUS_CHOICES = [('P','Pending'),('On-Track','On-Track'), ('Overdue','Overdue'), ('Completed','Completed')]
    PHASES = [('Pre-Engagement','Pre-Engagement'), ('Fieldwork','Fieldwork'), ('Reporting','Reporting'), ('Followup','Followup')]

    plan = models.ForeignKey(AuditPlan, on_delete=models.CASCADE)
    start_date = models.DateField()
    end_date = models.DateField()
    quarter = models.CharField(max_length=2, choices=QUARTERS)
    year = models.IntegerField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    status_details = models.TextField(blank=True, null=True)
    phase = models.CharField(max_length=20, choices=PHASES)

    def __str__(self):
        return f"{self.plan} - {self.quarter}"


# 7. Responsibility
class Responsibility(models.Model):
    description = models.CharField(max_length=255)

    def __str__(self):
        return self.description


# 8. Assignment
class Assignment(models.Model):
    performer_id = models.IntegerField()
    engagement = models.ForeignKey(Engagement, on_delete=models.CASCADE)
    responsibility = models.ForeignKey(Responsibility, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('performer_id', 'engagement', 'responsibility')


# 9. Findings
class Finding(models.Model):
    CRITICALITY = [('High','High'), ('Medium','Medium'), ('Low','Low')]
    RECTIFICATION_STATUS = [('Pending','Pending'), ('In Progress','In Progress'), ('Completed','Completed')]

    finding = models.TextField()
    criticality_level = models.CharField(max_length=10, choices=CRITICALITY)
    audit_team = models.CharField(max_length=255, blank=True, null=True)
    plan = models.ForeignKey(AuditPlan, on_delete=models.CASCADE)
    auditee_organization = models.CharField(max_length=255, blank=True, null=True)
    overdue_status = models.BooleanField(default=False)
    rectification_status = models.CharField(max_length=20, choices=RECTIFICATION_STATUS, default='Pending')
    rectification_percent = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    assigned_team = models.CharField(max_length=255, blank=True, null=True)
    rectification_description = models.TextField(blank=True, null=True)
    follow_up_date = models.DateField(blank=True, null=True)
    auditor_comments = models.TextField(blank=True, null=True)
    follower_id = models.IntegerField(blank=True, null=True)

    def __str__(self):
        return f"{self.finding[:50]}..."


# 10. Objective
class Objective(models.Model):
    objective_name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    target_value = models.DecimalField(max_digits=10, decimal_places=2)
    achieved_value = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    assigned_to = models.ForeignKey(Auditor, on_delete=models.CASCADE)

    @property
    def performance_percent(self):
        if self.target_value > 0:
            return round((self.achieved_value / self.target_value) * 100, 2)
        return 0

    def __str__(self):
        return self.objective_name


# 11. SubTask
class SubTask(models.Model):
    parent = models.ForeignKey(Objective, on_delete=models.CASCADE)
    sub_task_name = models.CharField(max_length=255)
    start_date = models.DateField()
    end_date = models.DateField()
    STATUS_CHOICES = [('Pending','Pending'), ('In Progress','In Progress'), ('Completed','Completed'), ('Overdue','Overdue')]
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    description = models.TextField(blank=True, null=True)
    progress_percent = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    assigned_to = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return self.sub_task_name
