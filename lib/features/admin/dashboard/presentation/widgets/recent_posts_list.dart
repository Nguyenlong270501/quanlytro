import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../approvals/data/models/landlord_summary.dart';
import '../../../approvals/presentation/property_request/property_approval_card.dart';
import '../../../../landlord/create_property/data/models/property_model.dart';

class RecentPostsList extends StatelessWidget {
  const RecentPostsList({
    super.key,
    required this.properties,
    required this.landlordSummaries,
  });

  final List<PropertyModel> properties;
  final Map<String, LandlordSummary> landlordSummaries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: properties.length,
      separatorBuilder: (context, index) => AppSizes.gapH10,
      itemBuilder: (context, index) {
        final property = properties[index];
        final landlordSummary = landlordSummaries[property.landlordId];
        return PropertyApprovalCard(
          property: property,
          landlordSummary: landlordSummary,
          onTap: () => context.push(
            RouteNames.adminPropertyApprovalDetail,
            extra: property,
          ),
        );
      },
    );
  }
}
