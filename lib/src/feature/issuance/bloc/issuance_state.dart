part of 'issuance_bloc.dart';

abstract class IssuanceState extends Equatable {
  final bool isRefreshFlow;

  double get stepperProgress => 0.0;

  bool get showStopConfirmation => true;

  bool get canGoBack => false;

  bool get didGoBack => false;

  IssuanceFlow? get flow => null;

  Organization? get organization => flow?.organization;

  const IssuanceState(this.isRefreshFlow);

  @override
  List<Object?> get props => [
        isRefreshFlow,
        stepperProgress,
        showStopConfirmation,
        canGoBack,
        didGoBack,
        flow,
        organization,
      ];
}

class IssuanceInitial extends IssuanceState {
  const IssuanceInitial(super.isRefreshFlow);
}

class IssuanceLoadInProgress extends IssuanceState {
  const IssuanceLoadInProgress(super.isRefreshFlow);
}

class IssuanceLoadFailure extends IssuanceState {
  const IssuanceLoadFailure(super.isRefreshFlow);
}

class IssuanceCheckOrganization extends IssuanceState {
  @override
  final IssuanceFlow flow;

  final bool afterBackPressed;

  @override
  Organization get organization => flow.organization;

  const IssuanceCheckOrganization(super.isRefreshFlow, this.flow, {this.afterBackPressed = false});

  @override
  List<Object?> get props => [flow, ...super.props];

  @override
  double get stepperProgress => 0.2;

  @override
  bool get didGoBack => afterBackPressed;
}

class IssuanceProofIdentity extends IssuanceState {
  @override
  final IssuanceFlow flow;

  final bool afterBackPressed;

  @override
  Organization get organization => flow.organization;

  List<Attribute> get requestedAttributes => flow.attributes;

  const IssuanceProofIdentity(super.isRefreshFlow, this.flow, {this.afterBackPressed = false});

  @override
  List<Object?> get props => [flow, ...super.props];

  @override
  bool get canGoBack => !isRefreshFlow;

  @override
  bool get didGoBack => afterBackPressed;

  @override
  double get stepperProgress => 0.4;
}

class IssuanceProvidePin extends IssuanceState {
  @override
  final IssuanceFlow flow;

  const IssuanceProvidePin(super.isRefreshFlow, this.flow);

  @override
  List<Object?> get props => [flow, ...super.props];

  @override
  bool get canGoBack => true;

  @override
  double get stepperProgress => 0.6;
}

class IssuanceCheckDataOffering extends IssuanceState {
  @override
  final IssuanceFlow flow;

  const IssuanceCheckDataOffering(super.isRefreshFlow, this.flow);

  @override
  List<Object?> get props => [flow, ...super.props];

  @override
  double get stepperProgress => 0.8;
}

class IssuanceSelectCards extends IssuanceState {
  @override
  final IssuanceFlow flow;

  final MultipleCardsFlow multipleCardsFlow;

  final bool showNoSelectionError;

  @override
  final bool didGoBack;

  List<WalletCard> get availableCards => flow.cards;

  List<WalletCard> get selectedCards => multipleCardsFlow.selectedCards;

  const IssuanceSelectCards(
    super.isRefreshFlow,
    this.flow,
    this.multipleCardsFlow, {
    this.didGoBack = false,
    this.showNoSelectionError = false,
  });

  @override
  List<Object?> get props => [flow, multipleCardsFlow, showNoSelectionError, ...super.props];

  @override
  double get stepperProgress => 0.8;

  IssuanceSelectCards toggleCard(String cardId) {
    final selection = Set<String>.from(multipleCardsFlow.selectedCardIds);
    return IssuanceSelectCards(
      isRefreshFlow,
      flow,
      multipleCardsFlow.copyWith(selectedCardIds: selection..toggle(cardId)),
    );
  }

  IssuanceSelectCards copyWith({bool? showNoSelectionError}) {
    return IssuanceSelectCards(
      isRefreshFlow,
      flow,
      multipleCardsFlow,
      showNoSelectionError: showNoSelectionError ?? this.showNoSelectionError,
      didGoBack: didGoBack,
    );
  }
}

class IssuanceCheckCards extends IssuanceState {
  @override
  final IssuanceFlow flow;

  final MultipleCardsFlow multipleCardsFlow;

  @override
  final bool didGoBack;

  WalletCard get cardToCheck => multipleCardsFlow.activeCard;

  int get totalNrOfCardsToCheck => multipleCardsFlow.selectedCards.length;

  const IssuanceCheckCards(
    super.isRefreshFlow, {
    required this.flow,
    required this.multipleCardsFlow,
    this.didGoBack = false,
  });

  IssuanceCheckCards copyForNextCard() {
    if (!multipleCardsFlow.hasMoreCards) throw UnsupportedError('There is no next card to check!');
    return IssuanceCheckCards(
      isRefreshFlow,
      flow: flow,
      multipleCardsFlow: multipleCardsFlow.next(),
      didGoBack: false,
    );
  }

  IssuanceCheckCards copyForPreviousCard() {
    if (multipleCardsFlow.isAtFirstCard) throw UnsupportedError('There is no previous card to check!');
    return IssuanceCheckCards(
      isRefreshFlow,
      flow: flow,
      multipleCardsFlow: multipleCardsFlow.previous(),
      didGoBack: true,
    );
  }

  @override
  List<Object?> get props => [flow, multipleCardsFlow, ...super.props];

  @override
  double get stepperProgress => 0.9;

  @override
  bool get canGoBack => true;
}

class IssuanceCompleted extends IssuanceState {
  @override
  final IssuanceFlow flow;

  final List<WalletCard> addedCards;

  const IssuanceCompleted(super.isRefreshFlow, this.flow, this.addedCards);

  @override
  List<Object?> get props => [flow, addedCards, ...super.props];

  @override
  bool get showStopConfirmation => false;
}

class IssuanceStopped extends IssuanceState {
  const IssuanceStopped(super.isRefreshFlow);

  @override
  List<Object> get props => [];

  @override
  bool get showStopConfirmation => false;
}

class IssuanceGenericError extends IssuanceState {
  const IssuanceGenericError(super.isRefreshFlow);

  @override
  List<Object> get props => [];

  @override
  bool get showStopConfirmation => false;
}

class IssuanceIdentityValidationFailure extends IssuanceState {
  const IssuanceIdentityValidationFailure(super.isRefreshFlow);

  @override
  List<Object> get props => [];

  @override
  bool get showStopConfirmation => false;
}
