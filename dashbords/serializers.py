from rest_framework import serializers
from .models import (
    AuditType, AuditObject, AuditPlan, Auditor, AuditeeOrganization,
    Engagement, Responsibility, Assignment, Finding, Objective, SubTask
)

# --- Audit Types ---
class AuditTypeSerializer(serializers.ModelSerializer):
    objects = serializers.StringRelatedField(many=True)  # Shows object names related

    class Meta:
        model = AuditType
        fields = ['id', 'type_name', 'objects']

# --- Audit Objects ---
class AuditObjectSerializer(serializers.ModelSerializer):
    type_id = AuditTypeSerializer(read_only=True)

    class Meta:
        model = AuditObject
        fields = ['id', 'object_name', 'description', 'type_id']

# --- Auditor ---
class AuditorSerializer(serializers.ModelSerializer):
    expertise_area = AuditTypeSerializer(read_only=True)

    class Meta:
        model = Auditor
        fields = ['id','job_title','department','expertise_area','auditor_name','contact_info','email','phone']

# --- Auditee Organization ---
class AuditeeOrganizationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditeeOrganization
        fields = ['id','organization_name','contact_person','contact_email','contact_phone']

# --- SubTask Serializer ---
class SubTaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = SubTask
        fields = ['id','sub_task_name','start_date','end_date','status','description','progress_percent','assigned_to']

# --- Objective Serializer (with nested SubTasks) ---
class ObjectiveSerializer(serializers.ModelSerializer):
    subtasks = SubTaskSerializer(many=True, read_only=True)

    class Meta:
        model = Objective
        fields = ['id','objective_name','description','target_value','achieved_value','performance_percent','assigned_to','subtasks']

# --- Responsibility Serializer ---
class ResponsibilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Responsibility
        fields = ['responsibility_id','description']

# --- Assignment Serializer ---
class AssignmentSerializer(serializers.ModelSerializer):
    performer = AuditorSerializer(read_only=True)
    engagement = serializers.StringRelatedField()
    responsibility = ResponsibilitySerializer(read_only=True)

    class Meta:
        model = Assignment
        fields = ['performer','engagement','responsibility']

# --- Finding Serializer ---
class FindingSerializer(serializers.ModelSerializer):
    plan_id = serializers.StringRelatedField()
    follower = AuditorSerializer(read_only=True)

    class Meta:
        model = Finding
        fields = [
            'finding_id','finding','criticality_level','audit_team','plan_id',
            'auditee_organization','overdue_status','rectification_status',
            'rectification_percent','assigned_team','rectificaton_description',
            'follow_up_date','auditor_comments','follower'
        ]

# --- Engagement Serializer (with nested Findings) ---
class EngagementSerializer(serializers.ModelSerializer):
    plan_id = serializers.StringRelatedField()
    findings = FindingSerializer(many=True, read_only=True)

    class Meta:
        model = Engagement
        fields = [
            'id','plan_id','start_date','end_date','quarter','year','status',
            'status_details','phase','findings'
        ]

# --- Audit Plan Serializer (with nested Engagements) ---
class AuditPlanSerializer(serializers.ModelSerializer):
    object_id = AuditObjectSerializer(read_only=True)
    audit_type_id = AuditTypeSerializer(read_only=True)
    engagements = EngagementSerializer(many=True, read_only=True)

    class Meta:
        model = AuditPlan
        fields = [
            'plan_id','object_id','plan_year','audit_type_id','planed_quarter',
            'plan_status','assigned_team','current_year','engagements'
        ]
