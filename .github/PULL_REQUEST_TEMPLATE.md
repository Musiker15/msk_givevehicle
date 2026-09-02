# Pull Request

## Description

<!-- What does this PR change and why? -->

## Type of change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that changes existing behavior)
- [ ] Documentation update
- [ ] NUI change

## Related issues

<!-- Link any related issues, e.g. Closes #123 -->

## Testing

<!-- How did you test this? -->

- [ ] Tested in-game on an ESX server
- [ ] Tested with `msk_garage` started
- [ ] Tested with `msk_garage` stopped
- [ ] Tested with a vehicle-key script
- [ ] Tested the server console commands (`_giveveh`, `_givejobveh`, `_delveh`, `spawnveh`)

## Checklist

- [ ] My code follows the style of the existing codebase
- [ ] Framework access goes through `msk_core`, not through ESX directly
- [ ] Every new dashboard action is permission-gated server-side
- [ ] Client input is validated server-side
- [ ] `owned_vehicles` queries stay filtered and paginated in SQL
- [ ] New server files are listed in `fxmanifest.lua`, with `server/admin/boot.lua` still last
- [ ] I rebuilt and committed `html/` if the NUI changed
- [ ] New strings were added to both `translation.lua` and the dashboard i18n
- [ ] I updated `CHANGELOG.md` and the documentation if behavior, config or the DB schema changed
