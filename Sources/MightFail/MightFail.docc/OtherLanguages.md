# Other Languages

## TypeScript

[TypeScript](https://mightfail.dev/)

```javascript
import { mightFail } from "might-fail"
const [networkError, result] = await mightFail(fetch("/posts"))

if (networkError) {
  // handle network error
  return
}

if (!result.ok) {
  // handle an error response from server
  return
}

const [convertToJSONError, posts] = await mightFail(
  result.json()
)

if (convertToJSONError) {
  // handle convertToJSONError
  return
}

posts.map((post) => console.log(post.title))
```