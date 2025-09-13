from django.urls import path, include
from rest_framework import routers
from .views import (
    AuditTypeViewSet, AuditObjectViewSet, AuditPlanViewSet, AuditorViewSet,
    AuditeeOrganizationViewSet, EngagementViewSet, ResponsibilityViewSet,
    AssignmentViewSet, FindingViewSet, ObjectiveViewSet, SubTaskViewSet
)

router = routers.DefaultRouter()
router.register(r'audit-types', AuditTypeViewSet)
router.register(r'audit-objects', AuditObjectViewSet)
router.register(r'audit-plans', AuditPlanViewSet)
router.register(r'auditors', AuditorViewSet)
router.register(r'auditees', AuditeeOrganizationViewSet)
router.register(r'engagements', EngagementViewSet)
router.register(r'responsibilities', ResponsibilityViewSet)
router.register(r'assignments', AssignmentViewSet)
router.register(r'findings', FindingViewSet)
router.register(r'objectives', ObjectiveViewSet)
router.register(r'sub-tasks', SubTaskViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
