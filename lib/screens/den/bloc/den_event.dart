part of 'den_bloc.dart';

@immutable
abstract class DenEvent {}

class LoadDen extends DenEvent {
  LoadDen(this.userAddress, this.params, {this.channels});

  final String userAddress;
  final List<String> channels;
  final Map<String, dynamic> params;
}

class LoadMoreDen extends DenEvent {}

class RefreshDen extends DenEvent {}

class DeleteDenExpression extends DenEvent {
  DeleteDenExpression(this.address);

  final String address;
}
