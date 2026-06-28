import '../features/acta_escrutinio/data/datasources/acta_local_data_source.dart';
import '../features/acta_escrutinio/data/repositories_impl/veedor_repository_impl.dart';
import '../features/acta_escrutinio/domain/repositories/veedor_repository.dart';
import '../features/acta_escrutinio/domain/usecases/capture_photo.dart';
import '../features/acta_escrutinio/domain/usecases/get_current_location.dart';
import '../features/acta_escrutinio/domain/usecases/save_acta_local.dart';
import '../features/acta_escrutinio/presentation/bloc/acta_bloc.dart';
import 'services/appwrite_service.dart';
import 'services/deep_link_service.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';
import '../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/change_password.dart';
import '../features/auth/domain/usecases/login_user.dart';
import '../features/auth/domain/usecases/logout_user.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/dashboard/data/repositories_impl/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/domain/usecases/create_coordinador_recinto.dart';
import '../features/dashboard/domain/usecases/create_recinto.dart';
import '../features/dashboard/domain/usecases/create_veedor.dart';
import '../features/dashboard/domain/usecases/get_coordinadores_recinto.dart';
import '../features/dashboard/domain/usecases/get_recinto.dart';
import '../features/dashboard/domain/usecases/get_recintos.dart';
import '../features/dashboard/domain/usecases/get_veedores_por_recinto.dart';
import '../features/dashboard/domain/usecases/reassign_veedor_mesa.dart';
import '../features/dashboard/domain/usecases/get_actas.dart';
import '../features/dashboard/domain/usecases/get_organizaciones_politicas.dart';
import '../features/dashboard/domain/usecases/get_parroquias.dart';
import '../features/dashboard/presentation/bloc/provincial_bloc.dart';
import '../features/dashboard/presentation/bloc/recinto_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Acta feature (Fase 4)
  late final ActaLocalDataSource actaLocalDataSource;
  late final VeedorRepository veedorRepository;
  late final CapturePhoto capturePhoto;
  late final GetCurrentLocation getCurrentLocation;
  late final SaveActaLocal saveActaLocal;
  late final ActaBloc actaBloc;

  // Auth feature (Fase 2)
  late final AuthRepository authRepository;
  late final LoginUser loginUser;
  late final ChangePassword changePassword;
  late final LogoutUser logoutUser;
  late final AuthBloc authBloc;

  // Dashboard feature (Fase 3)
  late final DashboardRepository dashboardRepository;
  late final GetRecintos getRecintos;
  late final GetRecinto getRecinto;
  late final CreateRecinto createRecinto;
  late final GetCoordinadoresRecinto getCoordinadoresRecinto;
  late final CreateCoordinadorRecinto createCoordinadorRecinto;
  late final GetVeedoresPorRecinto getVeedoresPorRecinto;
  late final CreateVeedor createVeedor;
  late final ReassignVeedorMesa reassignVeedorMesa;
  late final GetActas getActas;
  late final GetOrganizacionesPoliticas getOrganizacionesPoliticas;
  late final GetParroquias getParroquias;
  late final ProvincialBloc provincialBloc;
  late final RecintoBloc recintoBloc;

  // Sync service (Fase 5)
  late final SyncService syncService;
  late final DeepLinkService deepLinkService;

  void init() {
    actaLocalDataSource = ActaLocalDataSourceImpl();
    veedorRepository = VeedorRepositoryImpl(
      localDataSource: actaLocalDataSource,
    );
    capturePhoto = CapturePhoto(veedorRepository);
    getCurrentLocation = GetCurrentLocation(veedorRepository);
    saveActaLocal = SaveActaLocal(veedorRepository);
    actaBloc = ActaBloc(
      capturePhoto: capturePhoto,
      getCurrentLocation: getCurrentLocation,
      saveActaLocal: saveActaLocal,
    );

    authRepository = AuthRepositoryImpl();
    loginUser = LoginUser(authRepository);
    changePassword = ChangePassword(authRepository);
    logoutUser = LogoutUser(authRepository);
    authBloc = AuthBloc(
      loginUser: loginUser,
      changePassword: changePassword,
      logoutUser: logoutUser,
    );

    dashboardRepository = DashboardRepositoryImpl();
    getRecintos = GetRecintos(dashboardRepository);
    getRecinto = GetRecinto(dashboardRepository);
    createRecinto = CreateRecinto(dashboardRepository);
    getCoordinadoresRecinto = GetCoordinadoresRecinto(dashboardRepository);
    createCoordinadorRecinto = CreateCoordinadorRecinto(dashboardRepository);
    getVeedoresPorRecinto = GetVeedoresPorRecinto(dashboardRepository);
    createVeedor = CreateVeedor(dashboardRepository);
    reassignVeedorMesa = ReassignVeedorMesa(dashboardRepository);
    getActas = GetActas(dashboardRepository);
    getOrganizacionesPoliticas = GetOrganizacionesPoliticas(dashboardRepository);
    getParroquias = GetParroquias(dashboardRepository);

    provincialBloc = ProvincialBloc(
      getRecintos: getRecintos,
      getCoordinadores: getCoordinadoresRecinto,
      createRecinto: createRecinto,
      createCoordinador: createCoordinadorRecinto,
      getActas: getActas,
      getOrganizacionesPoliticas: getOrganizacionesPoliticas,
      getParroquias: getParroquias,
    );

    recintoBloc = RecintoBloc(
      getRecinto: getRecinto,
      getVeedores: getVeedoresPorRecinto,
      createVeedor: createVeedor,
      reassignVeedorMesa: reassignVeedorMesa,
    );

    syncService = SyncService(
      appwriteService: AppwriteService(),
      actasBox: LocalStorageService.actasLocalesBox,
      authBloc: authBloc,
    );

    deepLinkService = DeepLinkService(AppwriteService());
  }

  void dispose() {
    actaBloc.close();
    authBloc.close();
    provincialBloc.close();
    recintoBloc.close();
  }
}

final sl = InjectionContainer();
