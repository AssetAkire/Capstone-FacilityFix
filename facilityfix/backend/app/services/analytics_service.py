from typing import Dict, List, Any
from datetime import datetime, timedelta
from app.database.firestore_client import FirestoreClient
from app.services.concern_slip_service import ConcernSlipService
from app.services.job_service_service import JobServiceService
from app.services.work_order_permit_service import WorkOrderPermitService

class AnalyticsService:
    def __init__(self):
        self.db = FirestoreClient()
        self.concern_service = ConcernSlipService()
        self.job_service = JobServiceService()
        self.permit_service = WorkOrderPermitService()

    async def get_dashboard_stats(self) -> Dict[str, Any]:
        """Get key statistics for admin dashboard"""
        try:
            # Get counts for different statuses
            pending_concerns = await self.concern_service.get_pending_concern_slips()
            active_jobs = await self.job_service.get_jobs_by_status("in_progress")
            pending_permits = await self.permit_service.get_permits_by_status("pending")
            
            # Calculate completion rates
            total_concerns = await self.concern_service.get_all_concern_slips()
            completed_jobs = await self.job_service.get_jobs_by_status("completed")
            
            completion_rate = (len(completed_jobs) / len(total_concerns) * 100) if total_concerns else 0
            
            return {
                "pending_concerns": len(pending_concerns),
                "active_jobs": len(active_jobs),
                "pending_permits": len(pending_permits),
                "completion_rate": round(completion_rate, 2),
                "total_requests": len(total_concerns),
                "last_updated": datetime.now().isoformat()
            }
        except Exception as e:
            raise Exception(f"Failed to get dashboard stats: {str(e)}")

    async def get_work_order_trends(self, days: int = 30) -> Dict[str, Any]:
        """Get work order trends over specified period"""
        try:
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
            # Get all concern slips in date range
            all_concerns = await self.concern_service.get_all_concern_slips()
            
            # Filter by date range
            filtered_concerns = [
                concern for concern in all_concerns
                if start_date <= concern.created_at <= end_date
            ]
            
            # Group by day
            daily_counts = {}
            for concern in filtered_concerns:
                date_key = concern.created_at.strftime("%Y-%m-%d")
                daily_counts[date_key] = daily_counts.get(date_key, 0) + 1
            
            return {
                "period_days": days,
                "total_requests": len(filtered_concerns),
                "daily_breakdown": daily_counts,
                "average_per_day": len(filtered_concerns) / days if days > 0 else 0
            }
        except Exception as e:
            raise Exception(f"Failed to get work order trends: {str(e)}")

    async def get_category_breakdown(self) -> Dict[str, Any]:
        """Get breakdown of issues by category"""
        try:
            all_concerns = await self.concern_service.get_all_concern_slips()
            
            category_counts = {}
            priority_counts = {}
            
            for concern in all_concerns:
                # Count by category
                category = concern.category
                category_counts[category] = category_counts.get(category, 0) + 1
                
                # Count by priority
                priority = concern.priority
                priority_counts[priority] = priority_counts.get(priority, 0) + 1
            
            return {
                "categories": category_counts,
                "priorities": priority_counts,
                "total_analyzed": len(all_concerns)
            }
        except Exception as e:
            raise Exception(f"Failed to get category breakdown: {str(e)}")