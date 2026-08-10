import 'package:flutter/material.dart';
import '../../services/work_wanted_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF17324D);

class WorkerWorkWantedScreen extends StatefulWidget {
  const WorkerWorkWantedScreen({super.key});
  @override
  State<WorkerWorkWantedScreen> createState() => _WorkerWorkWantedScreenState();
}

class _WorkerWorkWantedScreenState extends State<WorkerWorkWantedScreen> {
  final _service = WorkWantedService();
  Map<String, dynamic>? _post;
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([_service.mine(), _service.categories()]);
    if (!mounted) return;
    final raw = results[1]['service_categories'];
    setState(() {
      _post =
          results[0]['post'] is Map
              ? Map<String, dynamic>.from(results[0]['post'])
              : null;
      _categories =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : [];
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkWantedEditor(post: _post, categories: _categories),
      ),
    );
    if (changed == true) await _load();
  }

  Future<void> _status(String status) async {
    final id = (_post?['id'] as num?)?.toInt();
    if (id == null) return;
    final result = await _service.setStatus(id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']?.toString() ?? 'Updated')),
    );
    if (result['success'] == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Looking for Work')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : _post == null
              ? _empty()
              : _content(),
    );
  }

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Color(0xFFE6F8F7),
            child: Icon(Icons.campaign_outlined, color: _primary, size: 38),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tell homeowners what work you want',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create one active post with your preferred services, location, work type and salary expectations.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _edit,
            style: FilledButton.styleFrom(backgroundColor: _primary),
            icon: const Icon(Icons.add),
            label: const Text('Create Looking for Work Post'),
          ),
        ],
      ),
    ),
  );

  Widget _content() {
    final services = (_post!['services'] as List? ?? [])
        .whereType<Map>()
        .map((e) => e['name']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .join(' • ');
    final status = _post!['status']?.toString() ?? 'active';
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _post!['title']?.toString() ?? 'Looking for Work',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                  ),
                  _pill(status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                services,
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '📍 ${_post!['district'] ?? ''}   •   ${_label(_post!['work_type'])}',
              ),
              const SizedBox(height: 12),
              Text(
                _post!['description']?.toString() ?? '',
                style: const TextStyle(height: 1.45),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _edit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          () =>
                              _status(status == 'active' ? 'paused' : 'active'),
                      style: FilledButton.styleFrom(backgroundColor: _primary),
                      child: Text(status == 'active' ? 'Pause' : 'Activate'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: _primary.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      status.toUpperCase(),
      style: const TextStyle(
        color: _primary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
  String _label(dynamic v) => (v?.toString() ?? '').replaceAll('_', ' ');
}

class WorkWantedEditor extends StatefulWidget {
  const WorkWantedEditor({super.key, this.post, required this.categories});
  final Map<String, dynamic>? post;
  final List<Map<String, dynamic>> categories;
  @override
  State<WorkWantedEditor> createState() => _WorkWantedEditorState();
}

class _WorkWantedEditorState extends State<WorkWantedEditor> {
  final _formKey = GlobalKey<FormState>();
  final _service = WorkWantedService();
  late final TextEditingController _title, _district, _description, _min, _max;
  String _workType = 'either', _living = 'either';
  bool _immediate = true, _relocate = false, _saving = false;
  final Set<int> _services = {};

  @override
  void initState() {
    super.initState();
    final p = widget.post ?? {};
    _title = TextEditingController(
      text: p['title']?.toString() ?? 'Available for domestic work',
    );
    _district = TextEditingController(text: p['district']?.toString() ?? '');
    _description = TextEditingController(
      text: p['description']?.toString() ?? '',
    );
    _min = TextEditingController(
      text: p['expected_salary_min']?.toString() ?? '',
    );
    _max = TextEditingController(
      text: p['expected_salary_max']?.toString() ?? '',
    );
    _workType = p['work_type']?.toString() ?? 'either';
    _living = p['living_preference']?.toString() ?? 'either';
    _immediate = p['available_immediately'] != false;
    _relocate = p['willing_to_relocate'] == true;
    for (final s in (p['services'] as List? ?? []))
      if (s is Map && s['id'] is num) _services.add((s['id'] as num).toInt());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one service.')),
      );
      return;
    }
    setState(() => _saving = true);
    final result = await _service.save(
      id: (widget.post?['id'] as num?)?.toInt(),
      data: {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'district': _district.text.trim(),
        'work_type': _workType,
        'living_preference': _living,
        'expected_salary_min': double.tryParse(_min.text.trim()),
        'expected_salary_max': double.tryParse(_max.text.trim()),
        'available_immediately': _immediate,
        'willing_to_relocate': _relocate,
        'service_ids': _services.toList(),
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']?.toString() ?? 'Saved')),
    );
    if (result['success'] == true) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.post == null ? 'Create Work Post' : 'Edit Work Post'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _field(_title, 'Post title', required: true),
          _field(_district, 'Preferred district', required: true),
          const SizedBox(height: 8),
          const Text(
            'Services you are looking for',
            style: TextStyle(fontWeight: FontWeight.w800, color: _navy),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.categories.map((c) {
                  final id = (c['id'] as num).toInt();
                  return FilterChip(
                    label: Text(c['name']?.toString() ?? 'Service'),
                    selected: _services.contains(id),
                    selectedColor: _primary.withValues(alpha: .16),
                    onSelected:
                        (v) => setState(
                          () => v ? _services.add(id) : _services.remove(id),
                        ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 18),
          _dropdown('Work type', _workType, {
            'either': 'Either',
            'full_time': 'Full-time',
            'part_time': 'Part-time',
          }, (v) => setState(() => _workType = v)),
          const SizedBox(height: 12),
          _dropdown('Living preference', _living, {
            'either': 'Either',
            'live_in': 'Live-in',
            'live_out': 'Live-out',
          }, (v) => setState(() => _living = v)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field(_min, 'Minimum salary', number: true)),
              const SizedBox(width: 10),
              Expanded(child: _field(_max, 'Maximum salary', number: true)),
            ],
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _immediate,
            activeColor: _primary,
            title: const Text('Available immediately'),
            onChanged: (v) => setState(() => _immediate = v),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _relocate,
            activeColor: _primary,
            title: const Text('Willing to relocate'),
            onChanged: (v) => setState(() => _relocate = v),
          ),
          _field(_description, 'Short message to homeowners', lines: 5),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(_saving ? 'Saving...' : 'Publish Looking for Work'),
          ),
        ],
      ),
    ),
  );

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    bool number = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      maxLines: lines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator:
          required
              ? (v) =>
                  v == null || v.trim().isEmpty ? '$label is required.' : null
              : null,
    ),
  );
  Widget _dropdown(
    String label,
    String value,
    Map<String, String> values,
    ValueChanged<String> changed,
  ) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
    items:
        values.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
    onChanged: (v) {
      if (v != null) changed(v);
    },
  );
}
