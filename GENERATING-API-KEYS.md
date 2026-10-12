# Generating API keys: Autotask, Datto RMM, and IT Glue

Before Claude can connect to your Kaseya tools, give it permission to do so. Each product uses a unique set of secret credentials called API keys to verify that the connection is coming from an authorized source. You generate those keys in each product by following the steps in this guide. After you have saved the keys, you will paste them into your Claude configuration file as described in [Step 2: Connect to MCP servers and install skills in Claude Desktop](README.md#step-2-connect-to-mcp-servers-and-install-skills-in-claude-desktop).

## A few things to know before you start

- You must be an administrator in each product. Generating API keys requires admin-level access in Autotask, IT Glue, and Datto RMM. If you do not have that access, ask whoever manages your Kaseya account to complete these steps and share the values with you securely.

- Secret values are shown only once. The secret or password portion of each key pair is displayed only when you generate it. After you leave the page, you cannot retrieve it. Have a secure place ready to store your values before you begin, such as a password manager or your IT Glue vault.

---

## Autotask

**Requirement:** Administrator role in Autotask.

1. In Autotask, select **Admin** in the left menu.

   <img width="328" height="356" alt="README Autotask1" src="https://github.com/user-attachments/assets/d27f57f1-550c-4b40-b268-8ec27e8d5f1e" />

2. Under **Admin** in the left menu, click **Resources (Users)**.

3. On the Resources page, select **New API User** from the **+ New** dropdown menu.

   <img width="600" height="255" alt="README Autotask2" src="https://github.com/user-attachments/assets/c22248c4-df5f-4088-ba77-c26b6f5c50a7" />

4. On the Add API User page, complete the required information for the new API user. Make sure the **Security Level** field is set to **API User**.

5. Click **Generate Key** and **Generate Secret**. Copy both values immediately and store them securely.

   <img width="543" height="455" alt="README Add api user in autotask top" src="https://github.com/user-attachments/assets/b1d5b755-46d8-4252-ab56-2174ae078b5d" />

6. In the **API Tracking Identifier** section, keep **Integration Vendor** selected, then search for and select **Autotask - MCP**.

   <img width="261" height="92" alt="README20" src="https://github.com/user-attachments/assets/2b617bbc-91af-4599-b0e2-eaefe7f0a0d0" />

7. Unless your business strictly separates work by line of business, leave the **Line of Business** field blank. Assigning one here can restrict what the API user can view.

8. Click **Save and Close**.

In addition to your Autotask API credentials, you are prompted for your Autotask MCP endpoint value when you connect. Use the table below to identify the MCP hostname to enter for this field.

### Australia (`au` — Azure `australiaeast`)

| Autotask API host | MCP hostname |
|---|---|
| `webservices29.autotask.net` | `mcp29.autotask.net` |
| `webservices30.autotask.net` | `mcp30.autotask.net` |
| `webservices31.autotask.net` | `mcp31.autotask.net` |

### Europe (`eu` — Azure `westeurope`)

| Autotask API host | MCP hostname |
|---|---|
| `webservices18.autotask.net` | `mcp18.autotask.net` |
| `webservices19.autotask.net` | `mcp19.autotask.net` |
| `webservices20.autotask.net` | `mcp20.autotask.net` |
| `prde.autotask.net` | `mcpprde.autotask.net` |

### United Kingdom (`uk` — Azure `uksouth`)

| Autotask API host | MCP hostname |
|---|---|
| `webservices4.autotask.net` | `mcp4.autotask.net` |
| `webservices11.autotask.net` | `mcp11.autotask.net` |
| `webservices16.autotask.net` | `mcp16.autotask.net` |
| `webservices17.autotask.net` | `mcp17.autotask.net` |
| `webservices28.autotask.net` | `mcp28.autotask.net` |

### United States (`us` — Azure `eastus2`)

| Autotask API host | MCP hostname |
|---|---|
| `webservices1.autotask.net` | `mcp1.autotask.net` |
| `webservices2.autotask.net` | `mcp2.autotask.net` |
| `webservices3.autotask.net` | `mcp3.autotask.net` |
| `webservices5.autotask.net` | `mcp5.autotask.net` |
| `webservices6.autotask.net` | `mcp6.autotask.net` |
| `webservices12.autotask.net` | `mcp12.autotask.net` |
| `webservices13.autotask.net` | `mcp13.autotask.net` |
| `webservices14.autotask.net` | `mcp14.autotask.net` |
| `webservices15.autotask.net` | `mcp15.autotask.net` |
| `webservices22.autotask.net` | `mcp22.autotask.net` |
| `webservices23.autotask.net` | `mcp23.autotask.net` |
| `webservices24.autotask.net` | `mcp24.autotask.net` |
| `webservices25.autotask.net` | `mcp25.autotask.net` |
| `webservices26.autotask.net` | `mcp26.autotask.net` |
| `webservices27.autotask.net` | `mcp27.autotask.net` |
| `pres.autotask.net` | `mcppres.autotask.net` |
| `prca01.autotask.net` | `mcpprca01.autotask.net` |

After you save your Autotask key and secret, and your MCP hostname, continue to the next product below to generate its API credentials.

For additional information about creating API users in Autotask, see [Adding or editing an API user](https://www.autotask.net/help/Content/4_Admin/1CompanySettings_Users/ResourcesUsersHR/Resources/API_User_Add_Edit.htm).

---

## Datto RMM

**Requirement:** Administrator role in Datto RMM.

### Step 1: Turn on API access

1. In Datto RMM, select **Setup > Global Settings** in the left menu.

2. On the Global Settings page, turn on the **Enable API Access** toggle in the **Access Control** section.

   <img width="600" height="252" alt="README RMM" src="https://github.com/user-attachments/assets/2cd84176-836a-4858-9523-c64d36108176" />

### Step 2: Generate keys for a user

1. In the left menu, select **Setup > Users**.

2. On the Users page, select the username for which you want to generate keys.

   <img width="353" height="344" alt="README RMM2" src="https://github.com/user-attachments/assets/3ada7607-cdbd-4449-a999-f8a04418b6d3" />

3. On the username page that displays, scroll down to the **API** section, then click **Generate API Keys**.

   <img width="600" height="393" alt="README RMM3" src="https://github.com/user-attachments/assets/fc200e7e-887c-43f4-861d-0f4ef6b68037" />

4. The **API Key** and **API Secret Key** display. Copy both values immediately and store them securely.

### Step 3: Identify the platform number

You are prompted to choose the platform for your Datto RMM account by number. Use the key below to determine which number to enter.

  | Platform number | Platform name |
  |---|---|
  | 1 | CONCORD |
  | 2 | MERLOT |
  | 3 | PINOTAGE |
  | 4 | SYRAH |
  | 5 | VIDAL |
  | 6 | ZINFANDEL |
  | 7 | MOSCATO |

> [!NOTE]
> API keys in Datto RMM bypass individual user security level restrictions. All keys grant the same level of access regardless of which user account generated them. Use caution when you decide who generates keys and where you store them.

For additional information about creating API keys in Datto RMM, see [Datto RMM API](https://rmm.datto.com/help/en/Content/2SETUP/APIv2.htm).

---

## IT Glue

**Requirement:** Administrator role in IT Glue.

1. In IT Glue, select **Admin** in the top menu, then **Settings** in the left menu.

   <img width="600" height="297" alt="README ITG" src="https://github.com/user-attachments/assets/34767e67-c6af-404a-a8c9-36a0a1c4986d" />

2. On the Settings page, select the **API Keys** tab.

3. In the **Custom API Keys** section, click **+ Create API Key**.

4. In the **Enter Name** field below, enter a name for the key, such as *Claude MCP*, then click **Generate Secret Key**. Copy the key value immediately and store it securely.

   <img width="600" height="42" alt="README ITG1" src="https://github.com/user-attachments/assets/f573d1ef-3d5c-44e4-b9dd-2ec74e8db3ea" />

5. Optionally, select the **Password Access** checkbox if you want the API key to retrieve password records from IT Glue. Leave it off if you do not need it.

> [!NOTE]
> Anyone with your IT Glue API key can access your data. Treat it like a password. Keep it private, do not share it by email or chat, and store it in a secure location. You can revoke a key and generate a new one at any time from your IT Glue account, but any connections that use the old key stop working immediately when you do.

For additional information about creating API keys in IT Glue, see [Getting started with the IT Glue API](https://help.itglue.kaseya.com/help/Content/1-admin/it-glue-api/getting-started-with-the-it-glue-api.html).

---

## Best practices

- Create a dedicated API user for Claude in each product. Rather than using a personal admin account, create a purpose-built API user specifically for this integration and give it a clear name such as *Claude MCP*. This helps you identify Claude connections, control access, and revoke credentials cleanly without affecting anyone else.

- Generate one set of keys per person setting up the integration. If multiple team members are configuring Claude separately, each person should generate their own keys rather than share one set. This makes it easier to track changes and rotate credentials individually if someone leaves.

- Use a dedicated service account, not a personal one. If a user account is deactivated or deleted in any of the three products, the API keys stop working immediately. Building the integration under a shared service account prevents disruption if a team member leaves.

- Revoking or regenerating a key immediately breaks existing connections. If you need to rotate a key, generate a new one in the relevant product, update the value in your Claude configuration file, and restart Claude Desktop. The old key stops working as soon as a new key is generated.

---

## Next step: Use your keys to configure Model Context Protocol (MCP) connections in Claude

After you have all three sets of credentials, return to the [README](README.md#getting-started) and follow **Step 1: Connecting your MCP servers**.

---

## Additional documentation

| Product | Reference |
|---|---|
| Autotask | [Adding or editing an API user](https://help.rocketcyber.kaseya.com/help/Content/integrations-troubleshooting-faqs/create-an-api-user-in-datto-psa-autotask.html) |
| Datto RMM | [Datto RMM API](https://rmm.datto.com/help/en/Content/2SETUP/APIv2.htm) |
| IT Glue | [Getting started with the IT Glue API](https://help.itglue.kaseya.com/help/Content/1-admin/it-glue-api/getting-started-with-the-it-glue-api.html) |
