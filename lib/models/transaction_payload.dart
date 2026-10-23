import 'package:my_app/models/transaction_detail_payload.dart';

class TransactionPayload {
  const TransactionPayload({
    required this.partnerName,
    required this.date,
    required this.details,
  });

  final String partnerName;
  final DateTime date;
  final List<TransactionDetailPayload> details;
}
