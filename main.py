class Middleware:
    def __init__(self):
        self.middlewares = []

    def add_middleware(self, middleware):
        self.middlewares.append(middleware)

    def remove_middleware(self, middleware):
        self.middlewares.remove(middleware)

    def execute(self, request):
        for middleware in self.middlewares:
            request = middleware(request)
        return request


class AuthenticationMiddleware:
    def __init__(self):
        pass

    def __call__(self, request):
        if request.get('authenticated', False):
            return request
        else:
            raise Exception('Auth error')


class RateLimitMiddleware:
    def __init__(self, max_requests):
        self.max_requests = max_requests
        self.requests = 0

    def __call__(self, request):
        self.requests += 1
        if self.requests > self.max_requests:
            raise Exception('Rate limit exceeded')
        return request


class LoggingMiddleware:
    def __init__(self):
        pass

    def __call__(self, request):
        print('Request received')
        return request


middleware = Middleware()
middleware.add_middleware(AuthenticationMiddleware())
middleware.add_middleware(RateLimitMiddleware(10))
middleware.add_middleware(LoggingMiddleware())

request = {'authenticated': True}
print(middleware.execute(request))

request = {'authenticated': False}
try:
    middleware.execute(request)
except Exception as e:
    print(e)

request = {'authenticated': True}
for i in range(11):
    try:
        middleware.execute(request)
    except Exception as e:
        print(e)