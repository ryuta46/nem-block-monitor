import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:nem_block_monitor_app/repository/user_data_repository.dart';

class LabelState {
  final bool isLoading;
  final BuiltMap<String, String> labels;
  final String error;

  static final _empty = BuiltMap<String, String>();

  LabelState({
    @required this.isLoading,
    @required this.labels,
    @required this.error
  });

  LabelState.initial(): isLoading = false, labels = _empty, error = "";

  LabelState.loading(): isLoading = true, labels = _empty, error = "";

  LabelState.failed(this.error): isLoading = false, labels = _empty;

  LabelState.success(this.labels): isLoading = false, error = "";
}


abstract class LabelEvent {}

class LabelLoadEvent extends LabelEvent {
}

class LabelAddEvent extends LabelEvent {
  final String address;
  final String label;
  LabelAddEvent(this.address, this.label);
}

class LabelRemoveEvent extends LabelEvent {
  final String address;
  LabelRemoveEvent(this.address);
}


class LabelBloc extends Bloc<LabelEvent, LabelState> {

  final UserDataRepository repository;

  LabelBloc(this.repository, String network) {
    repository.setTargetNetwork(network);
  }

  LabelState get initialState => LabelState.initial();

  void onLoaded() {
    dispatch(LabelLoadEvent());
  }

  void add(String address, String label) {
    dispatch(LabelAddEvent(address, label));
  }

  void remove(String address) {
    dispatch(LabelRemoveEvent(address));
  }

  @override
  Stream<LabelState> mapEventToState(LabelState state, LabelEvent event) async* {
    yield LabelState.loading();
    if (event is LabelLoadEvent) {
    }
    else if (event is LabelAddEvent) {
      await repository.addLabel(event.address, event.label);
    }
    else if (event is LabelRemoveEvent) {
      await repository.removeLabel(event.address);
    }
    yield LabelState.success(await repository.labels);
  }
}