---
source: https://www.checklist.design/mobile/login
category: mobile
captured: 2026-08-08
---

# Login

Everything a returning user needs to authenticate quickly and securely.

## Checklist

- **Social sign-in**: Sign-in options that connect to an existing Apple or Google account, bypassing manual credential entry.
  On iOS, Apple Sign In is required by App Store guidelines if any other social provider is offered.
- **Email field**: The input where users enter the email address associated with their account.
- **Password field**: A masked text input for the account password, with the option to reveal what has been typed.
- **Biometric authentication**: Face ID or fingerprint sign-in for returning users who have already authenticated once with a password
  Encouraged to suggest after initial login so it's a faster experience in the future
- **Credential autofill**: System-level support for pre-filling saved email and password from the user's password manager.
  textContentType on iOS and autoComplete on Android are the attributes that trigger native autofill.
- **Forgot password link**: The link users reach for when they can't recall their password, leading into the reset flow.
- **Error states**: Feedback shown when authentication fails, distinguishing between an unrecognised email address and an incorrect password.
  Generic 'incorrect credentials' gives users no useful signal — knowing whether the email or password is wrong helps them recover without guessing.
- **Passwordless sign-in (magic link)**: An alternative sign-in method that sends a one-time link to the user's email, requiring no password
  Useful for infrequent-use apps where remembering a password between sessions is difficult

## Documentation

(No separate Documentation tab found. This page instead has "Checklist" / "Inspiration" tabs — Inspiration appears to show visual reference examples rather than text documentation, and was not captured verbatim here.)

## Related

(Page also shows "On other platforms" links: Login (Website) — https://www.checklist.design/website/login; Login (Web app) — https://www.checklist.design/web-app/login)
- Resetting password (Flows) — https://www.checklist.design/flows/resetting-password
- Input Field (Design system) — https://www.checklist.design/design-system/input-field
- Verifying account (Flows) — https://www.checklist.design/flows/verifying-account
- Button (Design system) — https://www.checklist.design/design-system/button
- Toast (Design system) — https://www.checklist.design/design-system/toast
- 2FA (Web app) — https://www.checklist.design/web-app/2-factor-authentication
- Onboarding (Web app) — https://www.checklist.design/web-app/onboarding
