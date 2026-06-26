import '../features/acta_escrutinio/data/datasources/acta_local_data_source.dart';
import '../features/acta_escrutinio/presentation/bloc/acta_bloc.dart';
import '../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/change_password.dart';
import '../features/auth/domain/usecases/login_user.dart';
import '../features/auth/domain/usecases/logout_user.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  late final ActaLocalDataSource actaLocalDataSource;
  late final ActaBloc actaBloc;

  late final AuthRepository authRepository;
  late final LoginUser loginUser;
  late final ChangePassword changePassword;
  late final LogoutUser logoutUser;
  late final AuthBloc authBloc;

  void init() {
    // Acta feature (Fase 1 / Fase 4)
    actaLocalDataSource = ActaLocalDataSourceImpl();
    actaBloc = ActaBloc(localDataSource: actaLocalDataSource);

    // Auth feature (Fase 2)
    authRepository = AuthRepositoryImpl();
    loginUser = LoginUser(authRepository);
    changePassword = ChangePassword(authRepository);
    logoutUser = LogoutUser(authRepository);
    authBloc = AuthBloc(
      loginUser: loginUser,
      changePassword: changePassword,
      logoutUser: logoutUser,
    );
  }

  void dispose() {
    actaBloc.close();
    authBloc.close();
  }
}

final sl = InjectionContainer();
