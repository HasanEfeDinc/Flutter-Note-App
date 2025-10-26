import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteItem extends StatefulWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onPinToggle;

  const NoteItem({super.key, required this.note, this.onTap, this.onPinToggle});

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  bool _hover = false;

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _firstLine(String text, {int maxLength = 40}) {
    if (text.isEmpty) return 'No additional text';
    final firstLine = text.split('\n').first.trim();
    if (firstLine.length <= maxLength) return firstLine;
    return '${firstLine.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.note;
    final preview = _firstLine(n.preview);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(n.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                MouseRegion(
                  onEnter: (_) => setState(() => _hover = true),
                  onExit: (_) => setState(() => _hover = false),
                  child: InkWell(
                    onTap: widget.onPinToggle,
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      n.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 18,
                      color: n.pinned
                          ? Colors.amber.shade700
                          : (_hover ? Colors.amber.shade700 : Colors.grey.shade500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
