abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class ZohoAuthFailure extends Failure {
  const ZohoAuthFailure([super.message = 'Dealer account not registered or verified in Zoho CRM.']);
}

class PlumberVerificationFailure extends Failure {
  const PlumberVerificationFailure([super.message = 'Plumber verification pending or rejected.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local cached data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input parameters.']);
}

class CreditLimitExceededFailure extends Failure {
  const CreditLimitExceededFailure([super.message = 'Order value exceeds your available credit balance.']);
}
