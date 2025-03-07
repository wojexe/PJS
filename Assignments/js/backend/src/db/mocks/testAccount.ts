import { quoteString } from "./util";

export const queryString = () => {
  const userID = crypto.randomUUID();
  const sessionID = "7be2596c-b7f6-4a23-908c-30afebde1dfe";

  const user = [userID, "test_account", "store123"];
  const session = [sessionID, userID, new Date(8e13).toISOString()];

  return `
    INSERT INTO users VALUES (${user.map(quoteString).join(", ")});
    INSERT INTO sessions VALUES (${session.map(quoteString).join(", ")});
  `;
};
