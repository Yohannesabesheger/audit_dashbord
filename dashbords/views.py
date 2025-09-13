from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import (
    AuditType, AuditObject, AuditPlan, Auditor, AuditeeOrganization,
    Engagement, Responsibility, Assignment, Finding, Objective, SubTask
)
from .serializers import (
    AuditTypeSerializer, AuditObjectSerializer, AuditPlanSerializer, AuditorSerializer,
    AuditeeOrganizationSerializer, EngagementSerializer, ResponsibilitySerializer,
    AssignmentSerializer, FindingSerializer, ObjectiveSerializer, SubTaskSerializer
)


# --- AuditType ViewSet ---
class AuditTypeViewSet(viewsets.ModelViewSet):
    queryset = AuditType.objects.all()
    serializer_class = AuditTypeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['type_name']
    ordering_fields = ['id','type_name']


# --- AuditObject ViewSet ---
class AuditObjectViewSet(viewsets.ModelViewSet):
    queryset = AuditObject.objects.all()
    serializer_class = AuditObjectSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['object_name','description']
    ordering_fields = ['id','object_name']


# --- Auditor ViewSet ---
class AuditorViewSet(viewsets.ModelViewSet):
    queryset = Auditor.objects.all()
    serializer_class = AuditorSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['auditor_name','department','job_title']
    ordering_fields = ['id','auditor_name']


# --- Auditee Organization ViewSet ---
class AuditeeOrganizationViewSet(viewsets.ModelViewSet):
    queryset = AuditeeOrganization.objects.all()
    serializer_class = AuditeeOrganizationSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['organization_name','contact_person']
    ordering_fields = ['id','organization_name']


# --- SubTask ViewSet ---
class SubTaskViewSet(viewsets.ModelViewSet):
    queryset = SubTask.objects.all()
    serializer_class = SubTaskSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['sub_task_name','description']
    ordering_fields = ['id','start_date','end_date','status']


# --- Objective ViewSet (with nested SubTasks) ---
class ObjectiveViewSet(viewsets.ModelViewSet):
    queryset = Objective.objects.all()
    serializer_class = ObjectiveSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['objective_name','description']
    ordering_fields = ['id','target_value','achieved_value']


# --- Responsibility ViewSet ---
class ResponsibilityViewSet(viewsets.ModelViewSet):
    queryset = Responsibility.objects.all()
    serializer_class = ResponsibilitySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['description']
    ordering_fields = ['responsibility_id','description']


# --- Assignment ViewSet ---
class AssignmentViewSet(viewsets.ModelViewSet):
    queryset = Assignment.objects.all()
    serializer_class = AssignmentSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    ordering_fields = ['performer_id','engagement_id','responsibility_id']


# --- Findings ViewSet ---
class FindingViewSet(viewsets.ModelViewSet):
    queryset = Finding.objects.all()
    serializer_class = FindingSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['finding','audit_team','auditee_organization','assigned_team']
    ordering_fields = ['finding_id','criticality_level','rectification_status','overdue_status']


# --- Engagements ViewSet (nested Findings) ---
class EngagementViewSet(viewsets.ModelViewSet):
    queryset = Engagement.objects.prefetch_related('findings_set').all()
    serializer_class = EngagementSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['status','phase']
    ordering_fields = ['id','start_date','end_date','quarter','year']


# --- AuditPlan ViewSet (nested Engagements) ---
class AuditPlanViewSet(viewsets.ModelViewSet):
    queryset = AuditPlan.objects.prefetch_related('engagement_set').all()
    serializer_class = AuditPlanSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['plan_year','plan_status','assigned_team']
    ordering_fields = ['plan_id','plan_year','planed_quarter','plan_status']

    # Filter only current year plans
    def get_queryset(self):
        queryset = super().get_queryset()
        current_year = self.request.query_params.get('current_year', None)
        if current_year == 'true':
            queryset = queryset.filter(current_year=True)
        return queryset
