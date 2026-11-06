# Project conventions

For new Swift files, follow the existing seven-line comment header so imports/code begin on line 8:

```swift
//
//  FileName.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on M/D/YY.
//

import SwiftUI
```

Use the actual filename and creation date. Preserve existing headers when editing files; update the filename if a file is renamed.

## Comments and navigation

Use `// MARK: - Section Name` for meaningful sections in larger Swift files. Keep small, single-purpose files free of unnecessary section markers. Prefer comments explaining responsibility, intent, or non-obvious behavior; avoid narrating obvious controls or repeating function names. Preserve the existing file header.
