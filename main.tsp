import "@typespec/http";

using Http;

@service(#{ title: "Scoreboard Service", version: "1.0.0" })
@route("/api")
namespace ScoreboardService;

@format("uuid")
scalar uuid extends string;

model User {
  id: uuid;
  name: string;
  email: string;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
}

model UserRequest {
  name: string;
  email: string;
}

model UserList {
  items: User[];
}

model ScoreboardList {
  items: Scoreboard[];
}

model ScoreboardRequest {
  name: string;
}

model Scoreboard {
  id: uuid;
  name: string;
  authorId: uuid;
  authorName: string;
  items: ScoreboardItem[];
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
  deletedAt: utcDateTime;
}

model ScoreboardItem {
  id: uuid;
  userId: uuid;
  username: string;
  score: int32;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
  deletedAt: utcDateTime;
}

model ScoreboardItemRequest {
  userId: uuid;
  username: string;
  score: int32;
}

@tag("Users")
@route("/users")
namespace UserController {
  @get op list(): {
    status: 200;
    body: UserList[];
  } | {
    status: 500;
    body: ProblemDetails;
  };

  @post op create(@body body: UserRequest): {
    status: 200;
    body: User;
  } | {
    status: 500;
    body: ProblemDetails;
  };
}

@route("/scoreboards")
namespace ScoreboardController {
  /** List scoreboards */
  @tag("Scoreboards")
  @get op list(): {
    @body scoreboards: ScoreboardList[];
  } | {
    status: 500;
    body: ProblemDetails;
  };

  /** Create a scoreboard */
  @tag("Scoreboards")
  @post op createScoreboard(@body body: ScoreboardRequest): {
    status: 200;
    body: Scoreboard;
  } | {
    status: 500;
    body: ProblemDetails;
  };

  /** Read a scoreboard */
  @tag("Scoreboards")
  @get op read(@path id: uuid): {
    status: 200;
    body: Scoreboard;
  } | {
    status: 500;
    body: ProblemDetails;
  };

  /** Soft delete a scoreboard */
  @tag("Scoreboards")
  @delete op delete(@path id: uuid): {
    status: 204;
  } | {
    status: 500;
    body: ProblemDetails;
  };

  @route("/{id}/items")
  namespace ScoreboardItems {
    /** Create a scoreboard item */
    @tag("Scoreboard Items")
    @post op createScoreboardItem(@path id: uuid, @body body: ScoreboardItemRequest): {
      status: 200;
      body: ScoreboardItem;
    } | {
      status: 500;
      body: ProblemDetails;
    };

    /** Soft delete a scoreboard item */
    @tag("Scoreboard Items")
    @route("/{itemId}")
    @delete op deleteScoreboardItem(@path id: uuid, @path itemId: uuid): {
      status: 204;
    } | {
      status: 500;
      body: ProblemDetails;
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
