import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masoiree/core/form_validator.dart';
import 'package:masoiree/core/widgets/loading_overlay.dart';
import 'package:masoiree/core/widgets/status_message.dart';
import 'package:masoiree/features/authentication/authentication_provider.dart';
import 'package:masoiree/features/games/game_cards_service.dart';
import 'package:masoiree/features/games/models/game_card/game_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddUpdateGameCardDialog extends ConsumerStatefulWidget {
  const AddUpdateGameCardDialog({super.key, required this.gameID, required this.gameType, this.initialGameCard});

  final GameCard? initialGameCard;
  final String gameType;
  final int gameID;

  @override
  ConsumerState<AddUpdateGameCardDialog> createState() => _AddUpdateGameCardDialogState();
}

class _AddUpdateGameCardDialogState extends ConsumerState<AddUpdateGameCardDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();

  String _errorMessage = "";

  String? _cardType;

  @override
  void initState() {
    super.initState();

    _contentController.text = widget.initialGameCard?.content ?? "";
    _cardType = widget.initialGameCard?.type;
  }

  // @override
  // void didUpdateWidget(covariant AddUpdateGameCardDialog oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   _contentController.text = widget.initialGameCard?.content ?? "";
  //   _cardType = widget.initialGameCard?.type;
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.initialGameCard != null ? "Modifier la carte" : "Créer une carte",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            if (_errorMessage.isNotEmpty) ...[
              StatusMessage(
                message: _errorMessage,
              ),
              const SizedBox(
                height: 12,
              ),
            ],
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: "Le contenue de la carte",
                hintText: "Le contenue de la carte...",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              validator: FormValidator.requiredValidator,
            ),
            if (widget.gameType == "truthordare") ...[
              const SizedBox(
                height: 12,
              ),
              DropdownButtonFormField<String?>(
                value: _cardType,
                items: const [
                  DropdownMenuItem(value: null, child: Text("Choisir action ou vérité")),
                  DropdownMenuItem(
                    value: "dare",
                    child: Text("Action"),
                  ),
                  DropdownMenuItem(value: "truth", child: Text("Vérité")),
                ],
                decoration: const InputDecoration(
                  labelText: "Type de carte",
                ),
                onChanged: (value) {
                  setState(() {
                    _cardType = value;
                  });
                },
                validator: FormValidator.requiredValidator,
              ),
            ],
            const SizedBox(
              height: 20,
            ),
            FilledButton(onPressed: _onAddGameCard, child: Text(widget.initialGameCard != null ? "Modifier" : "Créer"))
          ],
        ),
      ),
    );
  }

  Future<void> _onAddGameCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = "";
      LoadingOverlay.of(context).show();
    });

    try {
      if (widget.initialGameCard != null) {
        await GameCardsService.instance
            .update(widget.initialGameCard!.id, _contentController.text, widget.gameID, type: _cardType, groupCode: ref.read(authenticationProvider)!.code);
      } else {
        await GameCardsService.instance.create(_contentController.text, widget.gameID, type: _cardType, groupCode: ref.read(authenticationProvider)!.code);
      }

      if (mounted) {
        LoadingOverlay.of(context).hide();
        Navigator.of(context).pop(true);
      }
    } on Exception {
      setState(() {
        _errorMessage = "Opération impossible...";
        LoadingOverlay.of(context).hide();
      });
    }
  }
}
