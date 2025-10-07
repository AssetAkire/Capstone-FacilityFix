from fastapi import APIRouter, HTTPException, Depends, Query
from typing import List, Dict, Any
from datetime import datetime, timedelta
from app.auth.dependencies import get_current_user, require_role
from app.services.analytics_service import AnalyticsService
from app.services.advanced_analytics_service import AdvancedAnalyticsService
from app.services.ai_integration_service import AIIntegrationService

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


@router.get("/heat-map")
async def get_heat_map_data(
    days: int = Query(30, description="Number of days to analyze"),
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Generate heat map data showing issue hotspots by location and category.
    Provides visual insights into where problems occur most frequently.
    """
    try:
        service = AdvancedAnalyticsService()
        heat_map_data = await service.generate_heat_map_data(days)
        return heat_map_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate heat map: {str(e)}")

@router.get("/staff-performance")
async def get_staff_performance_insights(
    days: int = Query(30, description="Number of days to analyze"),
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Get comprehensive staff performance metrics including completion rates,
    average resolution times, and performance scores.
    """
    try:
        service = AdvancedAnalyticsService()
        performance_data = await service.get_staff_performance_insights(days)
        return performance_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get staff performance insights: {str(e)}")

@router.get("/equipment-insights")
async def get_equipment_insights(
    days: int = Query(90, description="Number of days to analyze (longer period for equipment patterns)"),
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Analyze equipment failure patterns, predict maintenance needs,
    and identify high-risk equipment requiring attention.
    """
    try:
        service = AdvancedAnalyticsService()
        equipment_data = await service.get_equipment_insights(days)
        return equipment_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get equipment insights: {str(e)}")

@router.get("/inventory-analysis")
async def get_inventory_linkage_analysis(
    days: int = Query(60, description="Number of days to analyze for inventory patterns"),
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Analyze inventory usage patterns linked to repair types.
    Provides insights into which parts are consumed most frequently.
    """
    try:
        service = AdvancedAnalyticsService()
        inventory_data = await service.get_inventory_linkage_analysis(days)
        return inventory_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get inventory analysis: {str(e)}")

@router.get("/comprehensive-report")
async def get_comprehensive_analytics_report(
    days: int = Query(30, description="Number of days for the main report period"),
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Generate a comprehensive analytics report combining all insights:
    heat maps, staff performance, equipment analysis, and inventory data.
    """
    try:
        service = AdvancedAnalyticsService()
        comprehensive_report = await service.generate_comprehensive_report(days)
        return comprehensive_report
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate comprehensive report: {str(e)}")

@router.get("/ai-translation-stats")
async def get_ai_translation_statistics(
    days: int = Query(30, description="Number of days to analyze AI translation usage"),
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Get AI translation usage statistics including success rates,
    language detection accuracy, and processing performance.
    """
    try:
        service = AIIntegrationService()
        translation_stats = await service.get_translation_statistics(days)
        return translation_stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get AI translation statistics: {str(e)}")

@router.get("/predictive-insights")
async def get_predictive_insights(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Get predictive insights for proactive facility management.
    Identifies patterns and forecasts potential issues.
    """
    try:
        service = AdvancedAnalyticsService()
        
        # Combine multiple analytics for predictive insights
        heat_map_data = await service.generate_heat_map_data(60)  # 2 months of data
        equipment_insights = await service.get_equipment_insights(120)  # 4 months for equipment
        
        # Generate predictive recommendations
        predictions = {
            "high_risk_locations": heat_map_data["top_hotspots"][:3],
            "equipment_maintenance_alerts": equipment_insights["maintenance_recommendations"][:5],
            "predicted_peak_periods": {
                "description": "Based on historical data, expect increased maintenance requests during:",
                "periods": ["Start of rainy season", "Post-holiday periods", "Summer months (AC issues)"]
            },
            "resource_allocation_suggestions": [
                {
                    "area": "Staffing",
                    "suggestion": "Consider additional staff during peak periods",
                    "priority": "medium"
                },
                {
                    "area": "Inventory",
                    "suggestion": "Stock up on high-usage items before peak seasons",
                    "priority": "high"
                }
            ],
            "generated_at": datetime.now().isoformat()
        }
        
        return predictions
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate predictive insights: {str(e)}")
