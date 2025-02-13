import '../../../../domain/model/attribute/data_attribute.dart';
import '../../../../domain/model/attribute/requested_attribute.dart';
import '../../../../domain/model/card_front.dart';
import '../../../../domain/model/issuance_response.dart';
import '../../../../domain/model/policy/policy.dart';
import '../../../../domain/model/wallet_card.dart';
import '../../../source/organization_datasource.dart';
import '../../../source/wallet_datasource.dart';
import '../issuance_response_repository.dart';

part 'mock_issuance_response_repository.mocks.dart';

class MockIssuanceResponseRepository extends IssuanceResponseRepository {
  final WalletDataSource walletDataSource;
  final OrganizationDataSource organizationDataSource;

  MockIssuanceResponseRepository(this.walletDataSource, this.organizationDataSource);

  @override
  Future<IssuanceResponse> read(String issuanceRequestId) async {
    switch (issuanceRequestId) {
      case _kPidId:
        return IssuanceResponse(
          organization: (await organizationDataSource.read('rvig'))!,
          requestedAttributes: [],
          policy: _kMockIssuancePolicy,
          cards: [_kMockPidWalletCard],
        );
      case _kDiplomaId:
        return IssuanceResponse(
          organization: (await organizationDataSource.read('duo'))!,
          requestedAttributes: _kMockGovernmentOrganizationRequestedAttributes,
          policy: _kMockIssuancePolicy,
          cards: [_kMockDiplomaWalletCard],
        );
      case _kMultiDiplomaId:
        return IssuanceResponse(
          organization: (await organizationDataSource.read('duo'))!,
          requestedAttributes: _kMockGovernmentOrganizationRequestedAttributes,
          policy: _kMockIssuancePolicy,
          cards: [_kMockDiplomaWalletCard, _kMockMasterDiplomaWalletCard],
        );
      case _kDrivingLicenseId:
        return IssuanceResponse(
          organization: (await organizationDataSource.read('rdw'))!,
          requestedAttributes: _kMockGovernmentOrganizationRequestedAttributes,
          policy: _kMockIssuancePolicy,
          cards: [_kMockDrivingLicenseWalletCard],
        );
      case _kDrivingLicenseRenewedId:
        return IssuanceResponse(
          organization: (await organizationDataSource.read('rdw'))!,
          requestedAttributes: _kMockGovernmentOrganizationRequestedAttributes,
          policy: _kMockIssuancePolicy,
          cards: [_kMockDrivingLicenseRenewedWalletCard],
        );
      case _kHealthInsuranceId:
        return IssuanceResponse(
          organization: (await organizationDataSource.read('health_insurer_1'))!,
          requestedAttributes: _kMockHealthInsuranceRequestedAttributes,
          policy: _kMockIssuancePolicy,
          cards: [_kMockHealthInsuranceWalletCard],
        );
      case _kVOGId:
        return IssuanceResponse(
          organization: (await organizationDataSource.read('justis'))!,
          requestedAttributes: _kMockGovernmentOrganizationRequestedAttributes,
          policy: _kMockIssuancePolicy,
          cards: [_kMockVOGWalletCard],
        );
    }
    throw UnsupportedError('Unknown issuer: $issuanceRequestId');
  }
}
