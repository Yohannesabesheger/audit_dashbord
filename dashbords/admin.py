from django.contrib import admin
from django.contrib.admin import AdminSite



from .models import (
    AuditType, AuditObject, AuditPlan, Auditor, AuditeeOrganization,
    Engagement, Responsibility, Assignment, Finding, Objective, SubTask
)



# Optional: customize the admin site globally
admin.site.site_header = "Audit Management System"
admin.site.site_title = "Audit Dashboard"
admin.site.index_title = "Welcome to the Audit Management Portal"

# 1. AuditType
@admin.register(AuditType)
class AuditTypeAdmin(admin.ModelAdmin):
    list_display = ('id', 'type_name')
    search_fields = ('type_name',)

# 2. AuditObject
@admin.register(AuditObject)
class AuditObjectAdmin(admin.ModelAdmin):
    list_display = ('id', 'object_name', 'type')
    search_fields = ('object_name',)
    list_filter = ('type',)

# 3. AuditPlan
@admin.register(AuditPlan)
class AuditPlanAdmin(admin.ModelAdmin):
    list_display = ('id', 'object', 'plan_year', 'audit_type', 'planed_quarter', 'plan_status', 'current_year')
    list_filter = ('planed_quarter', 'plan_status', 'current_year', 'audit_type')
    search_fields = ('object__object_name', 'assigned_team')

# 4. Auditor
@admin.register(Auditor)
class AuditorAdmin(admin.ModelAdmin):
    list_display = ('id', 'auditor_name', 'job_title', 'department', 'expertise_area', 'email', 'phone')
    list_filter = ('department', 'expertise_area')
    search_fields = ('auditor_name', 'email')

# 5. AuditeeOrganization
@admin.register(AuditeeOrganization)
class AuditeeOrganizationAdmin(admin.ModelAdmin):
    list_display = ('id', 'organization_name', 'contact_person', 'contact_email', 'contact_phone')
    search_fields = ('organization_name', 'contact_person', 'contact_email')

# 6. Engagement
@admin.register(Engagement)
class EngagementAdmin(admin.ModelAdmin):
    list_display = ('id', 'plan', 'start_date', 'end_date', 'quarter', 'year', 'status', 'phase')
    list_filter = ('quarter', 'status', 'phase', 'year')
    search_fields = ('plan__object__object_name',)

# 7. Responsibility
@admin.register(Responsibility)
class ResponsibilityAdmin(admin.ModelAdmin):
    list_display = ('id', 'description')
    search_fields = ('description',)

# 8. Assignment
@admin.register(Assignment)
class AssignmentAdmin(admin.ModelAdmin):
    list_display = ('performer_id', 'engagement', 'responsibility')
    search_fields = ('engagement__plan__object__object_name',)

# 9. Finding
@admin.register(Finding)
class FindingAdmin(admin.ModelAdmin):
    list_display = ('id', 'finding', 'criticality_level', 'plan', 'rectification_status', 'rectification_percent')
    list_filter = ('criticality_level', 'rectification_status')
    search_fields = ('finding', 'plan__object__object_name', 'auditee_organization')

# 10. Objective
@admin.register(Objective)
class ObjectiveAdmin(admin.ModelAdmin):
    list_display = ('id', 'objective_name', 'assigned_to', 'target_value', 'achieved_value', 'performance_percent')
    search_fields = ('objective_name', 'assigned_to__auditor_name')

# 11. SubTask
@admin.register(SubTask)
class SubTaskAdmin(admin.ModelAdmin):
    list_display = ('id', 'sub_task_name', 'parent', 'status', 'progress_percent', 'assigned_to')
    list_filter = ('status',)
    search_fields = ('sub_task_name', 'parent__objective_name', 'assigned_to')
