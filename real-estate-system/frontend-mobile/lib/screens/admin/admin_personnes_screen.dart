import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import 'admin_personne_form_screen.dart';

class AdminPersonnesScreen extends StatefulWidget {
  const AdminPersonnesScreen({super.key});

  @override
  State<AdminPersonnesScreen> createState() => _AdminPersonnesScreenState();
}

class _AdminPersonnesScreenState extends State<AdminPersonnesScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();

  List<dynamic> _personnes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = _searchController.text.isNotEmpty
          ? await _api.searchPersonnes(_searchController.text)
          : await _api.getPersonnes();
      if (mounted) setState(() { _personnes = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  Future<void> _deletePersonne(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette personne ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.deletePersonne(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personne supprimée')));
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de supprimer (contrats actifs ?)')),
          );
        }
      }
    }
  }

  Future<void> _showInviteDialog(int personneId, String name) async {
    final emailCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inviter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Envoyer une invitation à $name'),
            const SizedBox(height: AppSpacing.space3),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                hintText: 'exemple@mail.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Envoyer')),
        ],
      ),
    );
    if (confirmed != true || emailCtrl.text.trim().isEmpty) {
      emailCtrl.dispose();
      return;
    }
    try {
      final result = await _api.inviteClient(personneId: personneId, email: emailCtrl.text.trim());
      final url = result['activationUrl'] as String?;
      if (mounted) {
        if (url != null) {
          _showActivationResult(url, name);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation envoyée')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
    emailCtrl.dispose();
  }

  void _showActivationResult(String url, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 48, color: AppColors.blue500),
              const SizedBox(height: AppSpacing.space3),
              Text('Invitation créée', style: AppTextStyles.textLg.w600),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Partagez ce lien avec $name pour activer son compte',
                style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: AppColors.slate200),
                ),
                child: QrImageView(
                  data: url,
                  size: 200,
                  backgroundColor: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Text(
                  url,
                  style: AppTextStyles.textSm.w400.withColor(AppColors.slate500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lien copié')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copier'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Share.share('Activez votre compte Horoazhon : $url');
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Partager'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.space3),
          color: AppColors.white,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Rechercher une personne...',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (_) => _loadData(),
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_personnes.isEmpty) return const EmptyState(icon: Icons.people_outlined, title: 'Aucune personne trouvée');

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: _personnes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              final p = _personnes[index] as Map<String, dynamic>;
              return Card(
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AdminPersonneFormScreen(personneId: p['id'] as int),
                    ));
                    _loadData();
                  },
                  borderRadius: AppRadius.lgAll,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outlined, color: AppColors.slate400),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p['prenom'] ?? ''} ${p['nom'] ?? ''}', style: AppTextStyles.textMd.w600),
                              if (p['ville'] != null) Text(p['ville'], style: AppTextStyles.textSm.w400),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                            const PopupMenuItem(value: 'invite', child: Text('Inviter')),
                            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                          ],
                          onSelected: (v) {
                            if (v == 'edit') {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => AdminPersonneFormScreen(personneId: p['id'] as int),
                              )).then((_) => _loadData());
                            }
                            if (v == 'invite') _showInviteDialog(p['id'] as int, '${p['prenom'] ?? ''} ${p['nom'] ?? ''}'.trim());
                            if (v == 'delete') _deletePersonne(p['id'] as int);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: AppSpacing.space4,
          right: AppSpacing.space4,
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const AdminPersonneFormScreen(),
              ));
              _loadData();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
