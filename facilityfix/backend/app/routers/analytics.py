from fastapi import APIRouter, HTTPException, Depends
from typing import List, Dict, Any
from datetime import datetime, timedelta
from app.auth.dependencies import get_current_user, require_role
from app.services.analytics_service import AnalyticsService

router = APIRouter(prefix="/analytics", tags=["analytics"])

@router.get("/dashboard-stats")
async def get_dashboard_stats(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get key dashboard statistics for admin overview"""
    try:
        service = AnalyticsService()
        stats = await service.get_dashboard_stats()
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get dashboard stats: {str(e)}")

@router.get("/work-order-trends")
async def get_work_order_trends(
    days: int = 30,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get work order trends over specified period"""
    try:
        service = AnalyticsService()
        trends = await service.get_work_order_trends(days)
        return trends
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get trends: {str(e)}")

@router.get("/category-breakdown")
async def get_category_breakdown(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get breakdown of issues by category"""
    try:
        service = AnalyticsService()
        breakdown = await service.get_category_breakdown()
        return breakdown
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get category breakdown: {str(e)}")
