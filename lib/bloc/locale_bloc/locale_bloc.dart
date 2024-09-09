// Bloc implementation
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_event.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(LocaleInitial()) {
    on<ChangeLocaleEvent>((event, emit) {
      emit(LocaleLoaded(event.locale));
    });
  }

  // Stream<LocaleState> mapEventToState(LocaleEvent event) async* {
  //   if (event is ChangeLocaleEvent) {
  //     yield LocaleLoaded(event.locale);
  //   }
  // }
}
