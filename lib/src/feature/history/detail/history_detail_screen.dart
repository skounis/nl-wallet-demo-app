import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../domain/model/attribute/data_attribute.dart';
import '../../../domain/model/policy/policy.dart';
import '../../../domain/model/timeline/interaction_timeline_attribute.dart';
import '../../../domain/model/timeline/operation_timeline_attribute.dart';
import '../../../domain/model/timeline/signing_timeline_attribute.dart';
import '../../../domain/model/timeline/timeline_attribute.dart';
import '../../common/widget/attribute/data_attribute_row.dart';
import '../../common/widget/bottom_back_button.dart';
import '../../common/widget/centered_loading_indicator.dart';
import '../../common/widget/document_section.dart';
import '../../common/widget/link_button.dart';
import '../../common/widget/placeholder_screen.dart';
import '../../common/widget/policy/policy_section.dart';
import 'argument/history_detail_screen_argument.dart';
import 'bloc/history_detail_bloc.dart';
import 'widget/history_detail_header.dart';
import 'widget/history_detail_timeline_attribute_row.dart';

class HistoryDetailScreen extends StatelessWidget {
  static HistoryDetailScreenArgument getArgument(RouteSettings settings) {
    final args = settings.arguments;
    try {
      return HistoryDetailScreenArgument.fromMap(args as Map<String, dynamic>);
    } catch (exception, stacktrace) {
      Fimber.e('Failed to decode $args', ex: exception, stacktrace: stacktrace);
      throw UnsupportedError('Make sure to pass in [HistoryDetailScreenArgument] when opening the HistoryDetailScreen');
    }
  }

  const HistoryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).historyDetailScreenTitle),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
      builder: (context, state) {
        if (state is HistoryDetailInitial) return _buildLoading();
        if (state is HistoryDetailLoadInProgress) return _buildLoading();
        if (state is HistoryDetailLoadSuccess) return _buildSuccess(context, state);
        throw UnsupportedError('Unknown state: $state');
      },
    );
  }

  Widget _buildLoading() {
    return const CenteredLoadingIndicator();
  }

  Widget _buildSuccess(BuildContext context, HistoryDetailLoadSuccess state) {
    final TimelineAttribute timelineAttribute = state.timelineAttribute;
    final bool showTimelineStatusRow = _showTimelineStatusRow(timelineAttribute);
    final bool showDataAttributesSection = _showDataAttributesSection(timelineAttribute);
    final bool showContractSection = _showContractSection(timelineAttribute);
    final List<Widget> slivers = [];

    // Header
    slivers.addAll([
      SliverToBoxAdapter(
        child: HistoryDetailHeader(
          organization: timelineAttribute.organization,
          dateTime: timelineAttribute.dateTime,
        ),
      ),
      const SliverToBoxAdapter(child: Divider(height: 1)),
    ]);

    // Interaction/operation type
    if (showTimelineStatusRow) {
      slivers.addAll([
        SliverToBoxAdapter(child: HistoryDetailTimelineAttributeRow(attribute: timelineAttribute)),
        const SliverToBoxAdapter(child: Divider(height: 1)),
      ]);
    }

    // Data attributes
    if (showDataAttributesSection) {
      // Section title
      slivers.add(SliverToBoxAdapter(child: _buildDataAttributesSectionTitle(context, timelineAttribute)));

      // Signed contract (optional)
      if (showContractSection) {
        final signingAttribute = (timelineAttribute as SigningTimelineAttribute);
        slivers.addAll([
          SliverToBoxAdapter(
            child: DocumentSection(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              document: signingAttribute.document,
              organization: signingAttribute.organization,
            ),
          ),
          const SliverToBoxAdapter(child: Divider(height: 32)),
        ]);
      }

      // Data attributes
      for (DataAttribute dataAttribute in timelineAttribute.dataAttributes) {
        slivers.add(SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DataAttributeRow(attribute: dataAttribute),
          ),
        ));
      }

      // Policy section
      final Policy? policy = _getPolicyToDisplay(timelineAttribute);
      if (policy != null) {
        slivers.add(const SliverToBoxAdapter(child: Divider(height: 32)));
        slivers.add(SliverToBoxAdapter(child: PolicySection(policy)));
      }

      // Incorrect button
      slivers.add(const SliverToBoxAdapter(child: Divider(height: 32)));
      slivers.add(SliverToBoxAdapter(child: _buildIncorrectButton(context)));
      slivers.add(const SliverToBoxAdapter(child: Divider(height: 32)));
    }

    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: CustomScrollView(
              slivers: slivers,
            ),
          ),
        ),
        const BottomBackButton(),
      ],
    );
  }

  bool _showTimelineStatusRow(TimelineAttribute attribute) {
    if (attribute is InteractionTimelineAttribute) {
      return attribute.status != InteractionStatus.success;
    } else if (attribute is SigningTimelineAttribute) {
      return attribute.status != SigningStatus.success;
    }
    return true;
  }

  bool _showDataAttributesSection(TimelineAttribute attribute) {
    if (attribute is InteractionTimelineAttribute) {
      return attribute.status == InteractionStatus.success;
    } else if (attribute is SigningTimelineAttribute) {
      return attribute.status == SigningStatus.success;
    }
    return true;
  }

  bool _showContractSection(TimelineAttribute timelineAttribute) {
    return (timelineAttribute is SigningTimelineAttribute) && timelineAttribute.status == SigningStatus.success;
  }

  Policy? _getPolicyToDisplay(TimelineAttribute timelineAttribute) {
    if (timelineAttribute is InteractionTimelineAttribute && timelineAttribute.status == InteractionStatus.success) {
      return timelineAttribute.policy;
    } else if (timelineAttribute is SigningTimelineAttribute && timelineAttribute.status == SigningStatus.success) {
      return timelineAttribute.policy;
    }
    return null;
  }

  Widget _buildDataAttributesSectionTitle(BuildContext context, TimelineAttribute attribute) {
    final locale = AppLocalizations.of(context);

    String title = '';
    if (attribute is InteractionTimelineAttribute) {
      title = locale.historyDetailScreenInteractionAttributesTitle;
    } else if (attribute is OperationTimelineAttribute) {
      title = locale.historyDetailScreenOperationAttributesTitle;
    } else if (attribute is SigningTimelineAttribute) {
      title = locale.historyDetailScreenSigningAttributesTitle;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline3,
          ),
        ],
      ),
    );
  }

  Widget _buildIncorrectButton(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: LinkButton(
          child: Text(AppLocalizations.of(context).cardDataScreenIncorrectCta),
          onPressed: () => PlaceholderScreen.show(context),
        ),
      ),
    );
  }
}
