from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AuditTypeViewSet, AuditObjectViewSet, AuditPlanViewSet, AuditorViewSet,
    AuditeeOrganizationViewSet, EngagementPlanViewSet, EngagementViewSet, ResponsibilityViewSet,
    AssignmentViewSet, FindingViewSet, ObjectiveViewSet, SubTaskViewSet
)

router = DefaultRouter()
router.register(r'audit-types', AuditTypeViewSet)
router.register(r'audit-objects', AuditObjectViewSet)
router.register(r'audit-plans', AuditPlanViewSet)
router.register(r'auditors', AuditorViewSet)
router.register(r'auditee-organizations', AuditeeOrganizationViewSet)
router.register(r'engagements', EngagementViewSet)
router.register(r'responsibilities', ResponsibilityViewSet)
router.register(r'assignments', AssignmentViewSet)
router.register(r'findings', FindingViewSet)
router.register(r'objectives', ObjectiveViewSet)
router.register(r'sub-tasks', SubTaskViewSet)
router.register(r'engagement-plans', EngagementPlanViewSet, basename='engagement-plan')


urlpatterns = [
    path('', include(router.urls)),
]
