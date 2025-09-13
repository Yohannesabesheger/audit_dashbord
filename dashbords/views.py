from rest_framework import viewsets
from .models import (
    AuditType, AuditObject, AuditPlan, Auditor, AuditeeOrganization,
    Engagement, Responsibility, Assignment, Finding, Objective, SubTask
)
from .serializers import (
    AuditTypeSerializer, AuditObjectSerializer, AuditPlanSerializer,
    AuditorSerializer, AuditeeOrganizationSerializer, EngagementPlanSerializer, EngagementSerializer,
    ResponsibilitySerializer, AssignmentSerializer, FindingSerializer,
    ObjectiveSerializer, SubTaskSerializer
)

# Generic viewsets
class AuditTypeViewSet(viewsets.ModelViewSet):
    queryset = AuditType.objects.all()
    serializer_class = AuditTypeSerializer

class AuditObjectViewSet(viewsets.ModelViewSet):
    queryset = AuditObject.objects.all()
    serializer_class = AuditObjectSerializer

class AuditPlanViewSet(viewsets.ModelViewSet):
    queryset = AuditPlan.objects.all()
    serializer_class = AuditPlanSerializer

class AuditorViewSet(viewsets.ModelViewSet):
    queryset = Auditor.objects.all()
    serializer_class = AuditorSerializer

class AuditeeOrganizationViewSet(viewsets.ModelViewSet):
    queryset = AuditeeOrganization.objects.all()
    serializer_class = AuditeeOrganizationSerializer

class EngagementViewSet(viewsets.ModelViewSet):
    queryset = Engagement.objects.all()
    serializer_class = EngagementSerializer


#=========================Change here for nested serializers=========================
class EngagementPlanViewSet(viewsets.ModelViewSet):
    queryset = Engagement.objects.all().select_related('plan', 'plan__object')
    serializer_class = EngagementPlanSerializer



class ResponsibilityViewSet(viewsets.ModelViewSet):
    queryset = Responsibility.objects.all()
    serializer_class = ResponsibilitySerializer

class AssignmentViewSet(viewsets.ModelViewSet):
    queryset = Assignment.objects.all()
    serializer_class = AssignmentSerializer

class FindingViewSet(viewsets.ModelViewSet):
    queryset = Finding.objects.all()
    serializer_class = FindingSerializer

class ObjectiveViewSet(viewsets.ModelViewSet):
    queryset = Objective.objects.all()
    serializer_class = ObjectiveSerializer

class SubTaskViewSet(viewsets.ModelViewSet):
    queryset = SubTask.objects.all()
    serializer_class = SubTaskSerializer
