import '../features/acta_escrutinio/data/datasources/acta_local_data_source.dart';
import '../features/acta_escrutinio/presentation/bloc/acta_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  late final ActaLocalDataSource actaLocalDataSource;
  late final ActaBloc actaBloc;
  late final AuthBloc authBloc;

  void init() {
    actaLocalDataSource = ActaLocalDataSourceImpl();
    actaBloc = ActaBloc(localDataSource: actaLocalDataSource);
    authBloc = AuthBloc();
  }

  void dispose() {
    actaBloc.close();
    authBloc.close();
  }
}

final sl = InjectionContainer();
