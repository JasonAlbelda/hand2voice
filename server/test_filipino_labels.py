import json
import os

# Test loading Filipino labels
filipino_labels_path = "assets/filipino_labels.json"

if os.path.exists(filipino_labels_path):
    with open(filipino_labels_path, 'r', encoding='utf-8') as f:
        labels = json.load(f)
    
    print(f"✅ Successfully loaded {len(labels)} Filipino labels\n")
    
    # Test some examples
    test_ids = ["0", "1", "7", "14", "15", "20", "100"]
    print("Sample Labels:")
    print("-" * 50)
    for id in test_ids:
        if id in labels:
            print(f"ID {id:>3}: {labels[id]}")
    
    print("\n" + "=" * 50)
    print("All labels loaded successfully!")
    print("=" * 50)
else:
    print("❌ Filipino labels file not found!")
    print(f"Expected path: {os.path.abspath(filipino_labels_path)}")
