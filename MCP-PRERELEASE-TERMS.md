# Kaseya MCP Servers — Pre-Release Terms

**Effective: [●] 2026**

These Pre-Release Terms ("**Pre-Release Terms**") govern your use of the Kaseya MCP servers and related materials. By installing, configuring or using any of them, or by clicking to accept these Pre-Release Terms, you agree to them on behalf of the organization you represent, and you confirm that you have authority to do so. If you do not agree, do not install or use them.

## 1. What these Pre-Release Terms cover

Kaseya Connectors are not yet generally available. These Pre-Release Terms apply to every alpha, beta, preview, early access or similar release of a Kaseya Connector, and each such release is a "Beta Product" under your Kaseya Agreement (defined below). They continue to apply until Kaseya makes the relevant Kaseya Connector generally available under its Product Terms of Use.

These Pre-Release Terms cover the following, each a "**Kaseya Connector**":

- the Kaseya-hosted Model Context Protocol (MCP) servers for Autotask PSA, Datto RMM and IT Glue, and any other Kaseya MCP server we add later;
- the extension bundles (`.mcpb` files), plugins and skills, installation and authentication scripts, and documentation that Kaseya publishes for them, including in the `kaseya/mcp-servers` repository.

## 2. How these Pre-Release Terms fit with your Kaseya agreement

a. **Kaseya Connectors are Kaseya Products.** Kaseya Connectors are Products and Beta Products under the [Kaseya Master Agreement](https://www.kaseya.com/legal/kaseya-master-agreement/) or other agreement under which you obtained the relevant Kaseya product (your "**Kaseya Agreement**"). Your Kaseya Agreement, the applicable Product Terms of Use and the [Kaseya Data Processing Addendum](https://www.kaseya.com/legal/kaseya-data-processing-addendum/) apply to your use of Kaseya Connectors, as supplemented by these Pre-Release Terms.

b. **Order of precedence.** If these Pre-Release Terms conflict with your Kaseya Agreement on any matter relating to Kaseya Connectors, these Pre-Release Terms control. Any signed addendum between you and Kaseya (for example, a DPA, NIS2, DORA or business associate addendum) continues to control on its subject matter. The Kaseya Insights Community documents in the repository (including its Code of Conduct, Governance Policy and Disclaimers) govern participation in that forum only and do not apply to Kaseya Connectors.

c. **The API License.** The [Kaseya API License](https://www.kaseya.com/legal/kaseya-api-license/) does not restrict your use of a Kaseya Connector in accordance with its documentation. These Pre-Release Terms are "more specific terms" for that purpose. In particular, using a Kaseya Connector with an AI Service as documented does not breach the API License, and an AI Service acting on your behalf through a Kaseya Connector is not a "third party" under it.

d. **Eligibility.** You may use a Kaseya Connector only if you have an active subscription to the Kaseya product it connects to and API access is enabled for your account in that product. Kaseya may make a Kaseya Connector available to some accounts or regions before others (for example, by enabling it account by account), and you may use a Kaseya Connector only where Kaseya makes it available to you. Tool vendors and integration developers may also use Kaseya Connectors as described in Section 6A.

## 3. Pre-release status

a. Kaseya Connectors are pre-release software and services. **They are provided "AS IS", without warranty of any kind and without any service level, uptime or support commitment.** They may contain errors, may produce inaccurate results and may change, be suspended or be discontinued at any time, with or without notice.

b. Kaseya does not charge for Kaseya Connectors. Calls made through a Kaseya Connector are API calls to the connected Kaseya product and count toward that product's API limits. If Kaseya introduces fees for API usage above a free tier, those fees apply in the same way whether calls come through a Kaseya Connector or directly; we will tell you before any fees apply.

c. You may not resell, sublicense or redistribute a Kaseya Connector. Integration Developers may use Kaseya Connectors only as described in Section 6A. Otherwise, your Kaseya Agreement governs how you may use Kaseya Connectors.

## 4. Your AI Service

a. A Kaseya Connector lets an artificial-intelligence application, assistant, agent or model that you choose (an "**AI Service**"), such as Claude, access and act on your Kaseya product data.

b. The AI Service is **Third-Party Technology** under your Kaseya Agreement. You select it, you control it, and your agreement with its provider governs it. **The AI Service provider is not Kaseya's subprocessor**, and Kaseya is not responsible for the AI Service, its security, its outputs or how its provider processes your data.

c. Once a Kaseya Connector returns Content to your AI Service, that Content leaves Kaseya's control. You are responsible for choosing an AI Service, and terms with its provider, that are appropriate for the Content you send it (for example, terms that do not allow the provider to train its models on your data).

d. Kaseya supports Kaseya Connectors only with the AI Services named in the documentation. Other AI Services may work, but you use them at your own risk and Kaseya does not support them.

## 5. Your responsibilities

a. **Authority over your clients' data.** If you are an MSP, the Content in your Kaseya products largely belongs to your clients. You are responsible for making sure that your agreements with them allow you to send their Content to the AI Service you use.

b. **Sensitive and regulated data.** Do not use a Kaseya Connector to send to an AI Service any protected health information, criminal justice information, export-controlled data, payment card data or other data that requires special handling, unless your agreement with the AI Service provider and applicable law permit it.

c. **Permissions and credentials.** Use a dedicated API user for each Kaseya Connector, grant the narrowest permissions the product allows, keep credentials secure, and revoke them when no longer needed. What a Kaseya Connector can see and change is limited by the permissions of the API user or key you give it. Some Kaseya products cannot scope API credentials below full account access (see the README); take that into account before connecting them. Do not enable password access on credentials used with a Kaseya Connector (for example, IT Glue's Password Access option) unless you need it.

d. **Review before you rely or act.** AI output may be wrong or incomplete. Review every proposed write or execute action before you approve it, and verify any report, score or recommendation before you rely on it or share it with anyone else (for example, with a client, auditor or insurer). Kaseya Connectors cannot verify that a person approved an action: whether you are asked to approve an action depends on your AI Service's settings. If you let your AI Service approve actions automatically, they will run without your review.

e. **Prompt injection.** Content in your Kaseya products, such as a ticket note, a document or a device name, can contain instructions that an AI Service may follow. Limit what your AI Service is permitted to do, and do not approve actions you did not intend.

f. **Security incidents.** Report any suspected compromise of a Kaseya Connector, or of credentials used with one, to Kaseya promptly through the channel in [SECURITY.md](Governance/SECURITY.md) and as your Kaseya Agreement requires.

## 6. Actions taken through a Kaseya Connector

Depending on the product and the permissions you grant, a Kaseya Connector may let your AI Service **create or change records** (for example, tickets, notes and time entries in Autotask, or documents in IT Glue), **permanently delete certain records** (for example, ticket checklist items in Autotask) or **run automation components from your component library on managed devices** (for example, in Datto RMM). Any action your AI Service takes through a Kaseya Connector using your credentials is **your action**, and you are responsible for it as if you had taken it yourself in the product. Your indemnification obligations under your Kaseya Agreement, including for claims by your clients and End Users, apply to your use of Kaseya Connectors and to those actions.

Your Kaseya product may record these actions under the API user or key whose credentials were used, not the person who directed your AI Service, and some Kaseya products do not yet show AI actions in their audit logs. If you need to know which person directed an action, give each person their own API user or key.

You may let your employees and contractors, including a tool vendor or other third party you engage, use a Kaseya Connector on your behalf. You are responsible for their use and for making sure they comply with these Pre-Release Terms. A third party that builds, supports or operates an Integration for you must also comply with Section 6A.

## 6A. Tool vendors and integration developers

a. **Who this Section covers.** This Section applies if you use a Kaseya Connector to build, test, support or operate an Integration for one or more Kaseya customers (an "**Integration Developer**"). "Integration", "Private Integration", "Public Integration" and "Integration Alliance Agreement" have the meanings given in the [Kaseya API License](https://www.kaseya.com/legal/kaseya-api-license/). For an Integration Developer, "your Kaseya Agreement" means the Kaseya API License, together with any Integration Alliance Agreement you have with Kaseya and, if you are also a Kaseya customer, your agreement as a customer.

b. **What you may build.** You may use a Kaseya Connector to build, test, support and operate a Private Integration for a Kaseya customer that engages you. To make an Integration that uses a Kaseya Connector available to more than one customer, or to include it in a product or service you offer, you need an Integration Alliance Agreement with Kaseya (for example, the Kaseya Technology Alliance Program or the Autotask Integration Hub) that covers it.

c. **Customer authorization and credentials.** You may access a Kaseya customer's Content through a Kaseya Connector only with that customer's authorization, and only with credentials the customer issues to you for that purpose. Do not use one customer's credentials for another customer, and revoke or return credentials when the customer asks or your engagement ends.

d. **Customer data.** Your processing of a customer's Content is governed by your agreement with that customer, not by the Kaseya DPA. You are not Kaseya's subprocessor, and Kaseya is not responsible to you or your customers for your Integration. Use developer, sandbox or trial accounts that Kaseya provides only for development and testing, and do not load a customer's real Content into them without that customer's agreement.

e. **Pre-release dependency.** Kaseya Connectors may change, break or be withdrawn at any time (Section 3(a)). Kaseya has no obligation to keep them compatible with your Integration or to support your Integration or your customers. Tell your customers that your Integration relies on pre-release Kaseya software.

f. **Your obligations.** Sections 4, 5, 6, 8, 10, 11 and 12 apply to you as they apply to a Kaseya customer. You may not present your Integration as a Kaseya product, or as endorsed or supported by Kaseya, and you may use Kaseya's names and trademarks only as your Kaseya Agreement allows.

g. **Responsibility for your Integration.** You will defend and indemnify Kaseya against third-party claims, including claims by your customers, arising from your Integration or your use of a Kaseya Connector, on the terms of the indemnification section of the Kaseya API License.

## 7. Data

a. Kaseya processes Content passing through a Kaseya-hosted MCP server under the Kaseya DPA, in the hosting region of the connected product (for example, the region of your Autotask zone, Datto RMM platform or IT Glue region).

b. Kaseya may record operational data about the use of Kaseya Connectors (for example, account or credential identifiers, tool names, request times, IP addresses, response statuses and durations) to operate, secure and improve the service and to measure usage. This is Administrative Data under your Kaseya Agreement.

c. Kaseya Connectors may not detect or block instructions aimed at AI Services. Any inspection or redaction that Kaseya provides reduces that risk but does not eliminate it.

d. **Support.** If you share Content with Kaseya for support, including in office hours, Kaseya and its service providers handle it under the Kaseya DPA. Do not post Content, credentials or vulnerability details in Discord, Teams, GitHub issues or other community channels; share Content only when Kaseya support asks for it, through the channel it specifies.

## 8. Confidentiality and public materials

Materials that Kaseya publishes in a public repository are not Kaseya Confidential Information. Non-public information about Kaseya Connectors that we share with you (for example, roadmaps or pre-release builds) remains Kaseya Confidential Information under your Kaseya Agreement.

Any comments, suggestions or ideas you give Kaseya about Kaseya Connectors are Feedback under your Kaseya Agreement. If your Kaseya Agreement does not give Kaseya a license to Feedback that covers Kaseya Connectors, you grant Kaseya a worldwide, perpetual, irrevocable, royalty-free license to use that Feedback for any purpose, without obligation to you.

## 9. Licenses

a. Documentation and skills published in the repository are licensed under the Apache License 2.0, unless a file or folder states otherwise.

b. Unless a file or folder states otherwise, extension bundles (`.mcpb` files), installation and authentication scripts and the hosted MCP services are proprietary to Kaseya and licensed to you only under these Pre-Release Terms and your Kaseya Agreement. Third-party open-source components are licensed under their own licenses.

## 10. Liability

Your Kaseya Agreement's exclusions and limitations of liability apply. To the maximum extent permitted by law, Kaseya's total liability arising out of or relating to Kaseya Connectors will not exceed the greater of (a) US$100 and (b) the fees you paid Kaseya for Kaseya Connectors in the six months before the event giving rise to the claim. Kaseya is not liable for any act or omission of an AI Service, or for any output of an AI Service. To the maximum extent permitted by law, Kaseya is also not liable for any loss, deletion or corruption of Content, any downtime or malfunction of a device or system, or any other harm resulting from an action taken through a Kaseya Connector using your credentials, including creating, changing or deleting records and running components on devices.

## 11. Restrictions

You will not use a Kaseya Connector:

- to circumvent API limits, rate limits or access controls;
- to perform penetration testing, load or stress testing, or vulnerability scanning of a Kaseya-hosted MCP server, except as the [Kaseya Vulnerability Disclosure Policy](https://www.kaseya.com/legal/vulnerability-disclosure-policy) permits;
- to develop or train any product, service or AI model that competes with a Kaseya product;
- in breach of sanctions or export-control laws, including in or for use in Russia, Belarus or any comprehensively sanctioned territory;
- for a government customer or in a regulated environment, if that use requires a certification or authorization that Kaseya has not confirmed in writing (for example, FedRAMP, StateRAMP, TX-RAMP or CMMC).

## 12. Changes, suspension and termination

Kaseya may update these Pre-Release Terms by posting a new version; the version posted when you use a Kaseya Connector applies. Previous versions are available in this repository's history. Kaseya may suspend or end your access to a Kaseya Connector, or disable any of its tools, at any time, without liability to you. You may stop using a Kaseya Connector at any time by removing it and revoking the credentials you created for it.

## 13. Governing law

These Pre-Release Terms are governed by the governing-law and venue provisions of your Kaseya Agreement.

## 14. Contact

Questions about these Pre-Release Terms: legal@kaseya.com. Product questions: use the support channels listed in the README.
