from rest_framework import serializers
from .models import (
    AuditType, AuditObject, AuditPlan, Auditor, AuditeeOrganization,
    Engagement, Responsibility, Assignment, Finding, Objective, SubTask
)

# --- AuditType Serializer ---
class AuditTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditType
        fields = '__all__'

# --- AuditObject Serializer ---
class AuditObjectSerializer(serializers.ModelSerializer):
    type = AuditTypeSerializer(read_only=True)
    type_id = serializers.PrimaryKeyRelatedField(
        queryset=AuditType.objects.all(), source='type', write_only=True
    )

    class Meta:
        model = AuditObject
        fields = '__all__'

# --- AuditPlan Serializer ---
class AuditPlanSerializer(serializers.ModelSerializer):
    object = AuditObjectSerializer(read_only=True)
    object_id = serializers.PrimaryKeyRelatedField(
        queryset=AuditObject.objects.all(), source='object', write_only=True
    )
    audit_type = AuditTypeSerializer(read_only=True)
    audit_type_id = serializers.PrimaryKeyRelatedField(
        queryset=AuditType.objects.all(), source='audit_type', write_only=True
    )

    class Meta:
        model = AuditPlan
        fields = '__all__'

# --- Auditor Serializer ---
class AuditorSerializer(serializers.ModelSerializer):
    expertise_area = AuditTypeSerializer(read_only=True)
    expertise_area_id = serializers.PrimaryKeyRelatedField(
        queryset=AuditType.objects.all(), source='expertise_area', write_only=True
    )

    class Meta:
        model = Auditor
        fields = '__all__'

# --- AuditeeOrganization Serializer ---
class AuditeeOrganizationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditeeOrganization
        fields = '__all__'

# --- Engagement Serializer ---
class EngagementSerializer(serializers.ModelSerializer):
    plan = AuditPlanSerializer(read_only=True)
    plan_id = serializers.PrimaryKeyRelatedField(
        queryset=AuditPlan.objects.all(), source='plan', write_only=True
    )

    class Meta:
        model = Engagement
        fields = '__all__'

# --- Responsibility Serializer ---
class ResponsibilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Responsibility
        fields = '__all__'

# --- Assignment Serializer ---
class AssignmentSerializer(serializers.ModelSerializer):
    engagement = EngagementSerializer(read_only=True)
    engagement_id = serializers.PrimaryKeyRelatedField(
        queryset=Engagement.objects.all(), source='engagement', write_only=True
    )
    responsibility = ResponsibilitySerializer(read_only=True)
    responsibility_id = serializers.PrimaryKeyRelatedField(
        queryset=Responsibility.objects.all(), source='responsibility', write_only=True
    )

    class Meta:
        model = Assignment
        fields = '__all__'

# --- Finding Serializer ---
class FindingSerializer(serializers.ModelSerializer):
    plan = AuditPlanSerializer(read_only=True)
    plan_id = serializers.PrimaryKeyRelatedField(
        queryset=AuditPlan.objects.all(), source='plan', write_only=True
    )

    class Meta:
        model = Finding
        fields = '__all__'

# --- Objective Serializer ---
class ObjectiveSerializer(serializers.ModelSerializer):
    assigned_to = AuditorSerializer(read_only=True)
    assigned_to_id = serializers.PrimaryKeyRelatedField(
        queryset=Auditor.objects.all(), source='assigned_to', write_only=True
    )
    performance_percent = serializers.ReadOnlyField()

    class Meta:
        model = Objective
        fields = '__all__'

# --- SubTask Serializer ---
class SubTaskSerializer(serializers.ModelSerializer):
    parent = ObjectiveSerializer(read_only=True)
    parent_id = serializers.PrimaryKeyRelatedField(
        queryset=Objective.objects.all(), source='parent', write_only=True
    )

    class Meta:
        model = SubTask
        fields = '__all__'


# --- EngagementPlan Serializer ---
# Serializer for Engagement (Nested)
class EngagementPlanSerializer(serializers.ModelSerializer):
    plan = AuditPlanSerializer(read_only=True)

    class Meta:
        model = Engagement
        fields = ('id', 'plan', 'start_date', 'end_date', 'quarter', 'year', 'status', 'status_details', 'phase')