export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // pretend _markdown doesnt exist
    if (url.pathname.startsWith("/_markdown/")) {
      return new Response("Not Found", {
        status: 404
      });
    }

    const accept = request.headers.get("Accept") || "";

    if (accept.includes("text/markdown")) {
      let path = url.pathname;

      if (path === "/") {
        path = "/index";
      } else {
        path = path.replace(/\/$/, "");
        path = path.replace(/\.html$/, "");
      }

      const markdownUrl = new URL(request.url);
      markdownUrl.pathname = `/_markdown${path}.md`;

      const markdown = await env.ASSETS.fetch(markdownUrl);

      if (markdown.ok) {
        const headers = new Headers(markdown.headers);

        headers.set(
          "Content-Type",
          "text/markdown; charset=utf-8"
        );
        headers.set("Vary", "Accept");

        return new Response(markdown.body, {
          status: markdown.status,
          headers
        });
      }
    }

    return env.ASSETS.fetch(request);
  }
};