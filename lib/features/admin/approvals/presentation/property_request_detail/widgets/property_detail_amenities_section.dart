import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../../../../landlord/create_property/presentation/shared_widgets/section_card.dart';
import '../../../../../landlord/property_tab/presentation/property_details/widgets/property_amenities_and_rules.dart';
import '../../property_request/widgets/pending_update_display_formatter.dart';
import '../../property_request/widgets/pending_value_banner.dart';

class PropertyDetailAmenitiesSection extends StatelessWidget {
  const PropertyDetailAmenitiesSection({
    super.key,
    required this.property,
    required this.pendingIndex,
  });

  final PropertyModel property;
  final PendingUpdateIndex? pendingIndex;

  List<Widget> _facilitiesBanners() {
    if (pendingIndex == null) return const [];
    final facilities = pendingIndex!.property('facilities');
    if (facilities == null) return const [];
    return [PendingValueBanner(line: facilities, caption: 'Tiện ích chung')];
  }

  List<Widget> _rulesBanners() {
    if (pendingIndex == null) return const [];
    final banners = <Widget>[];
    final rules = pendingIndex!.property('rules');
    if (rules != null) {
      banners.add(PendingValueBanner(line: rules, caption: 'Nội quy'));
    }
    final rulesDesc = pendingIndex!.property('rulesDescription');
    if (rulesDesc != null) {
      banners.add(
        PendingValueBanner(line: rulesDesc, caption: 'Ghi chú nội quy'),
      );
    }
    return banners;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          emoji: '✨',
          title: 'Tiện ích',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PropertyFacilitiesSection(property: property),
              ..._facilitiesBanners(),
            ],
          ),
        ),
        AppSizes.gapH16,
        SectionCard(
          emoji: '📜',
          title: 'Nội quy',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PropertyRulesSection(property: property),
              ..._rulesBanners(),
            ],
          ),
        ),
      ],
    );
  }
}
