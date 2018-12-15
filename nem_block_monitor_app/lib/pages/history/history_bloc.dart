import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:nem_block_monitor_app/model/notification.dart';
import 'package:nem_block_monitor_app/repository/user_data_repository.dart';


class HistoryState {
  final bool isLoading;
  final BuiltList<NotificationMessage> notifications;
  final String error;

  static final _empty = BuiltList<NotificationMessage>();

  const HistoryState({
    @required this.isLoading,
    @required this.notifications,
    @required this.error
  });

  HistoryState.initial(): isLoading = false, notifications = _empty, error = "";

  HistoryState.loading(): isLoading = true, notifications = _empty, error = "";

  HistoryState.failed(this.error): notifications = _empty, isLoading = false;

  HistoryState.success(this.notifications): isLoading = false, error = "";
}


abstract class HistoryEvent {}


class HistoryLoadEvent extends HistoryEvent {
}

class HistoryUpdateEvent extends HistoryEvent {
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final UserDataRepository repository;

  HistoryBloc(this.repository);

  HistoryState get initialState => HistoryState.initial();

  void onLoaded() {
    dispatch(HistoryLoadEvent());
  }

  void onNeedUpdate() {
    dispatch(HistoryUpdateEvent());
  }


  @override
  Stream<HistoryState> mapEventToState(HistoryState state, HistoryEvent event) async* {
    if (event is HistoryLoadEvent) {
      yield HistoryState.loading();
    }
    else if (event is HistoryUpdateEvent) {
    }
    try {
      yield HistoryState.success(await repository.getNotificationMessages());
    } catch (error) {
      yield HistoryState.failed(error.toString());
    }
  }
}