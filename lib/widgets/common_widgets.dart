import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Status badge widget for displaying request status
class StatusBadge extends StatelessWidget {
  final String status;
  final double? width;

  const StatusBadge({
    Key? key,
    required this.status,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayName = RequestStatus.getDisplayName(status);
    final color = RequestStatus.getStatusColor(status);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Priority badge widget for displaying request priority
class PriorityBadge extends StatelessWidget {
  final String priority;
  final double? width;

  const PriorityBadge({
    Key? key,
    required this.priority,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayName = PriorityLevels.getDisplayName(priority);
    final color = PriorityLevels.getPriorityColor(priority);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Role badge widget
class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayName = UserRoles.getDisplayName(role);
    Color color;

    switch (role) {
      case UserRoles.resident:
        color = AppColors.secondary;
        break;
      case UserRoles.coordinator:
        color = AppColors.accent;
        break;
      case UserRoles.supportWorker:
        color = AppColors.primary;
        break;
      case UserRoles.reviewer:
        color = AppColors.error;
        break;
      default:
        color = AppColors.gray600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Request card widget for list displays
class RequestCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? deadline;
  final VoidCallback? onTap;
  final bool showDeadline;

  const RequestCard({
    Key? key,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.deadline,
    this.onTap,
    this.showDeadline = true,
  }) : super(key: key);

  String? _getDeadlineText() {
    if (deadline == null) return null;
    
    final now = DateTime.now();
    final difference = deadline!.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in ${difference.inDays} days';
    }
  }

  Color? _getDeadlineColor() {
    if (deadline == null) return null;
    
    final now = DateTime.now();
    final difference = deadline!.difference(now);
    
    if (difference.isNegative) {
      return AppColors.error;
    } else if (difference.inDays <= 1) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.subtitle1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Description
              Text(
                description,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              // Priority and Deadline Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriorityBadge(priority: priority),
                  if (showDeadline && _getDeadlineText() != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _getDeadlineColor()?.withValues(alpha: 0.1),
                        border: Border.all(color: _getDeadlineColor()!),
                        borderRadius:
                            BorderRadius.circular(AppSizing.buttonRadius),
                      ),
                      child: Text(
                        _getDeadlineText()!,
                        style: TextStyle(
                          color: _getDeadlineColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null)
              Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  ElevatedButton(
                    onPressed: onButtonPressed,
                    child: Text(buttonText!),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Loading state widget
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null)
            Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message!,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Info banner widget
class InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onClose;

  const InfoBanner({
    Key? key,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.info.withOpacity(0.1),
        border: Border.all(color: backgroundColor ?? AppColors.info),
        borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor ?? AppColors.info,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor ?? AppColors.info,
                fontSize: 14,
              ),
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close,
                color: textColor ?? AppColors.info,
              ),
            ),
        ],
      ),
    );
  }
}

/// Deadline countdown widget
class DeadlineCountdown extends StatelessWidget {
  final DateTime deadline;
  final bool showOverdueHighlight;

  const DeadlineCountdown({
    Key? key,
    required this.deadline,
    this.showOverdueHighlight = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    final isOverdue = difference.isNegative;

    String displayText;
    Color displayColor;

    if (isOverdue) {
      displayText = 'OVERDUE ${difference.inDays.abs()} days';
      displayColor = showOverdueHighlight ? AppColors.error : AppColors.gray600;
    } else if (difference.inDays == 0) {
      displayText = 'DUE TODAY - ${difference.inHours} hours left';
      displayColor = AppColors.warning;
    } else if (difference.inDays == 1) {
      displayText = 'DUE TOMORROW';
      displayColor = AppColors.warning;
    } else {
      displayText = 'Due in ${difference.inDays} days';
      displayColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: 0.1),
        border: Border.all(color: displayColor),
        borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: displayColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// User info card widget
class UserInfoCard extends StatelessWidget {
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final VoidCallback? onEdit;

  const UserInfoCard({
    Key? key,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RoleBadge(role: role),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(color: AppColors.gray200),
            const SizedBox(height: AppSpacing.lg),
            _InfoRow(label: 'Email', value: email),
            const SizedBox(height: AppSpacing.md),
            if (phone != null) _InfoRow(label: 'Phone', value: phone!),
            if (phone != null) const SizedBox(height: AppSpacing.md),
            if (address != null) _InfoRow(label: 'Address', value: address!),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for info rows
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
