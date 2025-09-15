import 'dart:collection';
import '../services/ticket_service.dart';
import '../models/ticket.dart';
import '../models/ticket_factory.dart';
import '../services/user_service.dart';

class TicketRepository {
  TicketRepository._();
  static final TicketRepository instance = TicketRepository._();

  final TicketService _service = TicketService();
  final UserService _userService = UserService();

  List<Ticket> _cache = [];
  DateTime? _lastFetch;
  static const Duration _ttl = Duration(minutes: 5);
  bool _loading = false;

  bool get isStale =>
      _lastFetch == null || DateTime.now().difference(_lastFetch!) > _ttl;
  UnmodifiableListView<Ticket> get tickets => UnmodifiableListView(_cache);

  void invalidate() {
    _lastFetch = null;
  }

  Future<List<Ticket>> load({bool force = false}) async {
    if (_loading) return _cache;
    if (!force && !isStale) return _cache;
    _loading = true;
    try {
      final uid = await _userService.getCachedOrFetchUserId();
      if (uid == null) return _cache;
      final raw = await _service.getUserTicketFilterDefault(uid, context: null);
      _cache = raw
          .whereType<Map>()
          .map((e) => TicketFactory.createFromSearchMap(e))
          .where((t) => t.id > 0)
          .toList();
      _lastFetch = DateTime.now();
    } finally {
      _loading = false;
    }
    return _cache;
  }
}
