import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String datePosted;
  final String details;
  final String classification; // e.g., "utility", "power", "pest", "maintenance"
  final VoidCallback onTap;  

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.datePosted,
    required this.details,
    required this.classification,
    required this.onTap,
  });

  Color _getCardColor() {
    switch (classification.toLowerCase()) {
      case 'utility interruption':
        return const Color(0xFFEAECFD); // Blue-ish
      case 'power outage':
        return const Color(0xFFFDF6A3); // Yellow-ish
      case 'pest control':
        return const Color(0xFF91E5B0); // Green-ish
      case 'maintenance':
        return const Color(0xFFFFD4B1); // Orange-ish
      default:
        return const Color(0xFFEEEEEE); // Neutral Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: _getCardColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF282657),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            // Date Posted
            Opacity(
              opacity: 0.9,
              child: Text(
                'Posted $datePosted',
                style: const TextStyle(
                  color: Color(0xFF6F6F6F),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Mini Details
            Opacity(
              opacity: 0.9,
              child: Text(
                details,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6F6F6F),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.29,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Inventory Card
class InventoryCard extends StatefulWidget {
  final String itemName;
  final String priority; // Added priority field
  final String itemId;
  final String categoryLabel;
  final String quantity;

  const InventoryCard({
    super.key,
    required this.itemName,
    required this.priority,
    required this.itemId,
    required this.categoryLabel,
    required this.quantity,
  });

  @override
  State<InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<InventoryCard> {
  Color getPriorityColor() {
    switch (widget.priority.toLowerCase()) {
      case 'maintenance': 
        return const Color(0xFFF04438);
      case 'plumbing': 
        return const Color(0xFFF79009);
      case 'electrical': 
        return const Color(0xFF12B76A);
      case 'carpentry': 
        return const Color(0xFF12B76A);
      case 'others': 
        return const Color(0xFF12B76A);
      case 'high-turn over':
        return const Color(0xFFF04438);
      case 'critical use':
        return const Color(0xFFF79009);
      case 'repair prone':
        return const Color(0xFF667085);
      default:
        return const Color(0xFF667085);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = getPriorityColor();

    return Container(
      width: 334,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF6F7F9),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.black.withAlpha((0.10 * 255).toInt()),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: itemName + priority label with color
          SizedBox(
            width: 302,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.itemName,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.50,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: priorityColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    widget.priority,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.50,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Item ID
          SizedBox(
            width: 302,
            child: Text(
              'ID: ${widget.itemId}',
              style: const TextStyle(
                color: Color(0xFF4A5154),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1,
                fontFamily: 'Inter',
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Bottom row: category and quantity (simplified example)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: Colors.orange, // You can customize or add category color similarly
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  widget.categoryLabel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),

              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2, // change icon if needed
                      size: 14,
                      color: Color(0xFF101828),
                    ),
                    const SizedBox(width: 4), // space between icon and text
                    Text(
                      widget.quantity,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.50,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InventoryRequestCard extends StatelessWidget {
  final String itemName;
  final String requestId;
  final String itemType;
  final String status; // e.g., "Pending", "Approved", "Rejected"

  const InventoryRequestCard({
    super.key,
    required this.itemName,
    required this.requestId,
    required this.itemType,
    required this.status,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF79009); // orange
      case 'approved':
        return const Color(0xFF12B76A); // green
      case 'rejected':
        return const Color(0xFFF04438); // red
      default:
        return const Color(0xFF667085); // gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

    return Container(
      width: 334,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF6F7F9),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.black.withAlpha((0.10 * 255).toInt()),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Item Name + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  itemName,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.50,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: statusColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.50,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Request ID
          Text(
            'ID: $requestId',
            style: const TextStyle(
              color: Color(0xFF4A5154),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 8),

          // Item Type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              color: Colors.orange, // you can adjust color or make dynamic if needed
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              itemType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.50,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
