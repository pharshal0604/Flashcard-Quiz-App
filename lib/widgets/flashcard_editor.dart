import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/flashcard_data.dart';

class FlashcardEditor extends StatefulWidget {
  final String? initialQuestion;
  final String? initialAnswer;
  final String? initialCategory;
  final Function(String, String, String) onSave;

  const FlashcardEditor({
    super.key,
    this.initialQuestion,
    this.initialAnswer,
    this.initialCategory,
    required this.onSave,
  });

  @override
  State<FlashcardEditor> createState() => _FlashcardEditorState();
}

class _FlashcardEditorState extends State<FlashcardEditor> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _categoryController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initialQuestion);
    _answerController = TextEditingController(text: widget.initialAnswer);
    _categoryController = TextEditingController(text: widget.initialCategory);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcardData = Provider.of<FlashcardData>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Question is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Answer is required' : null,
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return flashcardData.categories;
                  }
                  return flashcardData.categories.where(
                    (category) => category.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                  );
                },
                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  _categoryController = controller;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Category is required' : null,
                  );
                },
                initialValue: widget.initialCategory != null
                    ? TextEditingValue(text: widget.initialCategory!)
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(
                      _questionController.text,
                      _answerController.text,
                      _categoryController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Flashcard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
