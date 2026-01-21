# alamir_supermarket

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firestore Security Rules

This project uses role-based access control (`customer`, `admin`, `owner`). Firestore rules are provided in `firebase/firestore.rules` and can be deployed using Firebase CLI.

### Prerequisites
- Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### Configure project
The project id is configured in `.firebaserc` as `market-8c0f1`. If your Firebase project id is different, update `.firebaserc`:

```json
{
	"projects": { "default": "<your-project-id>" }
}
```

### Deploy Firestore rules

```bash
firebase deploy --only firestore:rules
```

### Roles and permissions
- `owner`: full access; can create admins and manage everything
- `admin`: manage categories/products/orders
- `customer`: can read products/categories and create orders; can only edit safe fields in own user document

Rules file path: `firebase/firestore.rules`.
