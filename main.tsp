import "@typespec/http";

using Http;

@service(#{ title: "Scoreboard Service", version: "1.0.0" })
@route("/api")
namespace ScoreboardService;

@format("uuid")
scalar uuid extends string;

@format("email")
scalar email extends string;

model User {
  id: uuid;
  name: string;
  email: email;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
}

model PaginatedParams {
  @example(1)
  @query
  page?: int32;

  @example(10)
  @minValue(1)
  @maxValue(100)
  @query
  size?: int32;

  @example("asc")
  @query
  sort?: "asc" | "desc";

  @example("createdAt")
  @query
  sortBy?: string;
}

model PaginatedResponse<T> {
  items: T[];

  @example(10)
  totalPages: int32;

  @example(100)
  totalItems: int32;

  @example(1)
  currentPage: int32;

  @example(10)
  pageSize: int32;

  @example(true)
  hasNextPage: boolean;
}

@tag("Basic")
namespace BasicController {
  model LoginRequest {
    @example("admin")
    username: string;

    @example("password")
    password: string;
  }

  model LoginResponse {
    token: string;
    refreshToken: string;
  }

  model RegisterRequest {
    @example("username")
    username: string;

    @example("password")
    password: string;

    @example("email@example.com")
    email: email;
  }

  @route("/login")
  @post
  op login(@body body: LoginRequest): {
    @statusCode status: 200;
    @body body: LoginResponse;
  } | {
    @statusCode status: 401;
    @body body: ProblemDetails;
  };

  @route("/logout")
  @post
  op logout(): {
    @statusCode status: 204;
  };

  @route("/register")
  @post
  op register(@body body: RegisterRequest): {
    @statusCode status: 200;
    @body body: User;
  } | {
    @statusCode status: 400;
    @body body: ProblemDetails;
  };
}

@tag("Users")
@route("/users")
@useAuth(BearerAuth)
namespace UserController {
  model UserRequest {
    @example("John Doe")
    @minLength(1)
    @maxLength(20)
    name: string;

    email: email;

    @example("password")
    @minLength(8)
    @maxLength(20)
    @pattern("^[a-zA-Z0-9]+$")
    password: string;
  }

  @get op list(...PaginatedParams): {
    @statusCode status: 200;
    @body body: PaginatedResponse<User>;
  } | {
    @statusCode status: 500;
    @body body: ProblemDetails;
  };

  @post op create(@body body: UserRequest): {
    @statusCode status: 200;
    @body body: User;
  } | {
    @statusCode status: 500;
    @body body: ProblemDetails;
  };
}

@route("/scoreboards")
@useAuth(BearerAuth)
namespace ScoreboardController {
  model ScoreboardRequest {
    @example("My Scoreboard")
    name: string;
  }

  model Scoreboard {
    id: uuid;
    name: string;
    authorId: uuid;
    authorName: string;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  model ScoreboardItemRequest {
    userId: uuid;
    username: string;
    score: int32;
  }

  model ScoreboardItem {
    id: uuid;
    userId: uuid;
    username: string;
    score: int32;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  /** List scoreboards */
  @tag("Scoreboards")
  @get
  op list(...PaginatedParams): {
    @statusCode status: 200;
    @body body: PaginatedResponse<Scoreboard>;
  } | {
    @statusCode status: 500;
    @body body: ProblemDetails;
  };

  /** Create a scoreboard */
  @tag("Scoreboards")
  @post
  op createScoreboard(@body body: ScoreboardRequest): {
    @statusCode status: 200;
    @body body: Scoreboard;
  } | {
    @statusCode status: 500;
    @body body: ProblemDetails;
  };

  /** Update a scoreboard */
  @tag("Scoreboards")
  @put
  op updateScoreboard(@path id: uuid, @body body: ScoreboardRequest): {
    @statusCode status: 200;
    @body body: Scoreboard;
  } | {
    @statusCode status: 500;
    @body body: ProblemDetails;
  };

  /** Read a scoreboard */
  @tag("Scoreboards")
  @get
  op read(@path id: uuid): {
    @statusCode status: 200;
    @body body: Scoreboard;
  } | {
    @statusCode status: 500;
    @body body: ProblemDetails;
  };

  /** Soft delete a scoreboard */
  @tag("Scoreboards")
  @delete
  op delete(@path id: uuid): {
    @statusCode status: 204;
  } | {
    @statusCode status: 500;
    @body body: ProblemDetails;
  };

  @route("/{id}/items")
  namespace ScoreboardItems {
    @tag("Scoreboard Items")
    @get
    op listScoreboardItems(@path id: uuid, ...PaginatedParams): {
      @statusCode status: 200;
      @body body: PaginatedResponse<ScoreboardItem>;
    } | {
      @statusCode status: 500;
      @body body: ProblemDetails;
    };
    
    /** Create a scoreboard item */
    @tag("Scoreboard Items")
    @post
    op createScoreboardItem(
      @path id: uuid,
      @body body: ScoreboardItemRequest,
    ): {
      @statusCode status: 200;
      @body body: ScoreboardItem;
    } | {
      @statusCode status: 500;
      @body body: ProblemDetails;
    };

    /** Soft delete a scoreboard item */
    @tag("Scoreboard Items")
    @route("/{itemId}")
    @delete
    op deleteScoreboardItem(@path id: uuid, @path itemId: uuid): {
      @statusCode status: 204;
    } | {
      @statusCode status: 500;
      @body body: ProblemDetails;
    };
  }
}

@error
model ProblemDetails {
  type: string;
  title: string;
  status: int32;
  detail: string;
  instance: string;
}
