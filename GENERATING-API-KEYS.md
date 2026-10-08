# Generating API Keys: Autotask, Datto RMM, and IT Glue

Before Claude can connect to your Kaseya tools, you need to give it permission to do so. 
Each product — Autotask, Datto RMM, and IT Glue — uses a unique set of secret 
credentials called API keys to verify that the connection is coming from an authorized 
source. You'll generate those keys inside each product using the steps in this guide, then 
paste them into Claude's configuration file to complete the connection.

**A few things to know before you start:**

- **You must be an administrator in each product.** Generating API keys requires 
  admin-level access in Autotask, IT Glue, and Datto RMM. If you don't have that 
  access, ask whoever manages your Kaseya account to complete these steps and 
  share the values with you securely.

- **Secret values are only shown once.** The secret or password portion of each key 
  pair is displayed only at the moment it's generated. Once you navigate away, it 
  cannot be retrieved. Have a secure place ready to store your values before you 
  begin — a password manager or your IT Glue vault works well.

---

## Autotask

**Requirement:** Admin-level role in Autotask.

1. From the Autotask dashboard, navigate to the **Admin** section in the left menu.

<img width="328" height="356" alt="README Autotask1" src="https://github.com/user-attachments/assets/d27f57f1-550c-4b40-b268-8ec27e8d5f1e" />


2. Click **Resources (Users)** from the left navigation.

3. Select **New API User** from the **+ New** dropdown menu.

<img width="600" height="255" alt="README Autotask2" src="https://github.com/user-attachments/assets/c22248c4-df5f-4088-ba77-c26b6f5c50a7" />


4. Fill out the required information for the new API user; make sure the **Security Level** 
   is set to **API User**.

5. Click **Generate Key** and **Generate Secret**. Copy both values immediately and 
   store them securely.

  <img width="543" height="455" alt="README Add api user in autotask top" src="https://github.com/user-attachments/assets/b1d5b755-46d8-4252-ab56-2174ae078b5d" />

6. In the **API Tracking Identifier** section, keep the Integration Vendor option selected and search for **Autotask - MCP**. This is what you will input for the **integration code value.**

<img width="261" height="92" alt="README20" src="https://github.com/user-attachments/assets/2b617bbc-91af-4599-b0e2-eaefe7f0a0d0" />

7. Unless your business strictly separates work by line of business, leave the **Line of 
   Business** field blank. Assigning one here can restrict what the API user can see.

8. Click **Save & Close**.

Once you have your Autotask key and secret saved, continue to the next product below. 
When you have all three sets of credentials, return to the README to complete the 
connection.

For additional information on creating API users in Autotask, see: 
[Adding or editing an API user](https://help.rocketcyber.kaseya.com/help/Content/integrations-troubleshooting-faqs/create-an-api-user-in-datto-psa-autotask.html)

---

## IT Glue

**Requirement:** Administrator role in IT Glue.

1. Navigate to **Admin > Settings**.

<img width="600" height="297" alt="README ITG" src="https://github.com/user-attachments/assets/34767e67-c6af-404a-a8c9-36a0a1c4986d" />

2. Select the **API Keys** tab.

3. Click **Custom API Keys > Create API Key**.

4. Enter a name for the key — for example, *Claude MCP* — and click **Generate API 
   Key**. Copy your key value immediately and store it securely.

<img width="600" height="42" alt="README ITG1" src="https://github.com/user-attachments/assets/f573d1ef-3d5c-44e4-b9dd-2ec74e8db3ea" />

5. Optionally, enable **Password Access** if you want the API key to be able to retrieve 
   password records from IT Glue. Leave this off if you don't need it.

> **IT Glue security note:** Anyone who has your IT Glue API key can access your 
> data. Treat it like a password — keep it private, don't share it over email or chat, 
> and store it in a secure location. You can revoke a key and generate a new one at 
> any time from your IT Glue account, but any connections using the old key will stop 
> working immediately when you do.

Once you have your IT Glue API key saved, continue to Datto RMM below.

For additional information on creating API keys in IT Glue, see:
[Getting started with the IT Glue API](https://help.itglue.kaseya.com/help/Content/1-admin/it-glue-api/getting-started-with-the-it-glue-api.html)

---

## Datto RMM

**Requirement:** Admin role in Datto RMM.

### Step 1 — Enable API access (one-time setup, skip if already enabled)

1. Inside Datto RMM, navigate to **Setup > Global Settings > Access Control**.
2. Turn on the **Enable API Access** toggle.

<img width="600" height="252" alt="README RMM" src="https://github.com/user-attachments/assets/2cd84176-836a-4858-9523-c64d36108176" />

### Step 2 — Generate keys for a user

1. Navigate to **Setup > Users** and click the username you want to generate keys for.

<img width="353" height="344" alt="README RMM2" src="https://github.com/user-attachments/assets/3ada7607-cdbd-4449-a999-f8a04418b6d3" />

2. Scroll down to the **API** section and click **Generate API Keys**.

<img width="600" height="393" alt="README RMM3" src="https://github.com/user-attachments/assets/fc200e7e-887c-43f4-861d-0f4ef6b68037" />

3. Your **API Key** and **API Secret Key** will be displayed. Copy both values 
   immediately and store them securely.

> **Datto RMM security note:** API keys in Datto RMM bypass individual user security 
> level restrictions — all keys grant the same level of access regardless of which user 
> account they were generated under. For this reason, be deliberate about who 
> generates keys and where those keys are stored.

---

## Best Practices

- **Create a dedicated API user for Claude in each product.** Rather than using a 
  personal admin account, set up a purpose-built API user specifically for this 
  integration and give it a clear name like *Claude MCP*. This makes it easy to 
  identify Claude's connections, control access, and revoke credentials cleanly 
  without affecting anyone else.

- **Generate one set of keys per person setting this up.** If multiple team members 
  are configuring Claude separately, each should generate their own keys rather than 
  sharing one set. This makes it easier to track who made changes and to rotate 
  credentials individually if someone leaves.

- **Use a dedicated service account, not a personal one.** If a user account is 
  deactivated or deleted in any of the three products, their API keys stop working 
  immediately. Building the integration under a shared service account prevents 
  disruption if a team member leaves.

- **Revoking or regenerating a key immediately breaks existing connections.** If you 
  need to rotate a key, regenerate it in the relevant product, update the value in your 
  Claude configuration file, and restart Claude Desktop. The old key stops working 
  the moment a new one is generated.

---

## Next Step: Use your keys to configure MCP connections in Claude

Now that you have all three sets of credentials, return to the [README](README.md#getting-started) and follow **Step 1: Connecting your MCP servers.**

---

## Additional Documentation

| Product | Reference |
|---|---|
| Autotask | [Adding or editing an API user](https://help.rocketcyber.kaseya.com/help/Content/integrations-troubleshooting-faqs/create-an-api-user-in-datto-psa-autotask.html) |
| Datto RMM | [Datto RMM API](https://rmm.datto.com/help/en/Content/2SETUP/APIv2.htm) |
| IT Glue | [Getting started with the IT Glue API](https://help.itglue.kaseya.com/help/Content/1-admin/it-glue-api/getting-started-with-the-it-glue-api.html) |
