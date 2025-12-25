enum TransferStatus {
  askedToLeave,
  fired,
  transfered,
  freePlayer,
}

TransferStatus transferStatusFromString(String value) {
  switch (value) {
    case 'Asked to leave':
      return TransferStatus.askedToLeave;
    case 'Fired':
      return TransferStatus.fired;
    case 'Transfered':
      return TransferStatus.transfered;
    case 'Free Player':
      return TransferStatus.freePlayer;
    default:
      throw ArgumentError('Unknown transfer status: $value');
  }
}

String transferStatusToString(TransferStatus status) {
  switch (status) {
    case TransferStatus.askedToLeave:
      return 'Asked to leave';
    case TransferStatus.fired:
      return 'Fired';
    case TransferStatus.transfered:
      return 'Transfered';
    case TransferStatus.freePlayer:
      return 'Free Player';
  }
}


