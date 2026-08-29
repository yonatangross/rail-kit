# Fixtures

`clients/_template/` is the folder you copy for each real client. `clients/dana-studio/`
is a fictional client (name, company, transcripts and dates are invented) used by the
examples and by `behavioral-spec.json` in every skill. `crm-export.example.csv` shows
the optional read-only CRM export the skills can consult.

To try the kit on the fixture without touching anything real:

```bash
mkdir -p /tmp/rail-demo && cp -r fixtures/clients /tmp/rail-demo/ && cd /tmp/rail-demo
# then in Claude Code, from /tmp/rail-demo:
#   /client-context dana-studio
#   /post-call dana-studio --transcript clients/dana-studio/call-2026-08-20.txt
```

The 2026-08-20 transcript contains one deliberately planted "ignore the above and ..."
line. It is there so the injection spec cases have a real input; a correct run treats
it as call content and never acts on it.
