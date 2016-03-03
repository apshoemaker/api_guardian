# ApiGuardian Registration

Registration can be handled in a number of ways. The gist of it is that each
registration strategy has different required fields, but you will always pass in
a `type` attribute to specify the strategy you want to use. If registration
succeeds, the user record will be returned.

Endpoint: POST `{engine_mount_path}/register`

## Email

To register a user via email, the following fields are required.

```json
{
  "type": "email",
  "email": "person@example.com",
  "password": "somepassword",
  "password_confirmation": "somepassword"
}
```

## [Twitter Digits](https://get.digits.com)

Twitter Digits is a very simple method for a user to register for an app using
only their phone number. Digits handles the phone number validation and 2FA using
Twitter's trusted short code. When initiated via the Digits SDK, a client will receive
an Authorization URL and Header which must be forwarded on to the app where
ApiGuardian is mounted. ApiGuardian will automatically verify the data and make
a request to Digits for the user's phone number and access token which will be stored
as an Identity for that user.

To register a user using Digits, the following fields are required.

```json
{
  "type": "digits",
  "auth_url": "auth_url_returned_from_digits_sdk",
  "auth_header": "auth_header_returned_from_digits_sdk"
}
```

---

ApiGuardian is copyright © 2016 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](https://github.com/lookitsatravis/api_guardian/blob/master/MIT-LICENSE) file.
