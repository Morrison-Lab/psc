# Claude Instructions

## Code Review Format

When performing code reviews (via `/code-review:code-review`), append the following at the very end of the review comment, after all individual issue entries and their "Fix this" links:

---

[🔧 Fix all issues](https://github.com/d-morrison/qwt/issues/new?title=Fix+all+review+issues+in+PR+%23PR_NUMBER&body=%40claude+please+fix+all+the+issues+identified+in+the+code+review+of+pull+request+%23PR_NUMBER)

---

Replace `PR_NUMBER` in the URL with the actual pull request number being reviewed.

This link opens a pre-filled GitHub issue that triggers Claude to fix every issue identified in the review at once, as a complement to the individual per-issue "Fix this" links.
